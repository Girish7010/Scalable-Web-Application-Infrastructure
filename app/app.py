from flask import Flask, jsonify
import os, json, time, psycopg2, boto3

app = Flask(__name__)

def get_db_creds():
    sm = boto3.client("secretsmanager", region_name=os.environ.get("AWS_REGION","us-east-1"))
    data = sm.get_secret_value(SecretId=os.environ["DB_SECRET_ARN"])["SecretString"]
    return json.loads(data)

def get_conn():
    c = get_db_creds()
    return psycopg2.connect(user=c["username"], password=c["password"], host=c["host"], port=c["port"], dbname=c["dbname"])

@app.route("/healthz")
def healthz():
    return jsonify(ok=True, ts=int(time.time()))

@app.route("/")
def index():
    try:
        conn = get_conn()
        cur = conn.cursor()
        cur.execute("""
            CREATE TABLE IF NOT EXISTS messages(
                id SERIAL PRIMARY KEY,
                content TEXT NOT NULL,
                created_at TIMESTAMP DEFAULT NOW()
            );
        """)
        conn.commit()
        cur.execute("SELECT COUNT(*) FROM messages;")
        if cur.fetchone()[0] == 0:
            cur.execute("INSERT INTO messages(content) VALUES(%s)", ("Hello from ECS + RDS!",))
            conn.commit()
        cur.execute("SELECT id, content, created_at FROM messages ORDER BY id DESC LIMIT 10;")
        rows = cur.fetchall()
        cur.close(); conn.close()
        return jsonify(status="ok", rows=[{"id":r[0],"content":r[1],"created_at":r[2].isoformat()} for r in rows])
    except Exception as e:
        return jsonify(error=str(e)), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
