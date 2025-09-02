# RDS subnet group (private subnets)
resource "aws_db_subnet_group" "db" {
  name       = "${var.project_name}-db-subnet"
  subnet_ids = [for s in aws_subnet.private : s.id]
}

# Strong DB password
resource "random_password" "db_password" {
  length  = 20
  special = true
}

# RDS PostgreSQL (private)
resource "aws_db_instance" "postgres" {
  identifier_prefix = "${var.project_name}-pg-"
  engine            = "postgres"
  engine_version    = "16.3"
  instance_class    = var.db_instance_class
  allocated_storage = var.db_allocated_storage

  db_subnet_group_name   = aws_db_subnet_group.db.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  username = var.db_username
  password = random_password.db_password.result
  db_name  = var.db_name

  multi_az                = false
  publicly_accessible     = false
  skip_final_snapshot     = true
  backup_retention_period = var.rds_backup_retention

  tags = {
    Name = "${var.project_name}-rds"
  }
}

# Store DB connection in Secrets Manager (JSON)
resource "aws_secretsmanager_secret" "db_secret" {
  name = "${var.project_name}-db-conn"
}

resource "aws_secretsmanager_secret_version" "db_secret_value" {
  secret_id = aws_secretsmanager_secret.db_secret.id
  secret_string = jsonencode({
    username = var.db_username,
    password = random_password.db_password.result,
    host     = aws_db_instance.postgres.address,
    port     = 5432,
    dbname   = var.db_name
  })
}

# Bastion host in a public subnet (for SSH into ECS instances)
resource "aws_instance" "bastion" {
  ami                         = data.aws_ssm_parameter.ecs_ami.value
  instance_type               = "t3.micro"
  subnet_id                   = values(aws_subnet.public)[0].id
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true
  key_name                    = var.key_pair_name

  user_data = base64encode(<<-EOT
    #!/bin/bash
    yum update -y
  EOT
  )

  tags = {
    Name = "${var.project_name}-bastion"
  }
}
