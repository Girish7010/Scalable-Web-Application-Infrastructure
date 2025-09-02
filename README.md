# Scalable Web Application on AWS ECS + EC2

A production-ready, scalable web application built with Flask, deployed on AWS ECS with EC2 instances, featuring blue-green deployments, auto-scaling, monitoring, and a PostgreSQL RDS database.

## 🏗️ Architecture Overview

This project implements a modern, scalable web application infrastructure on AWS with the following components:

```
Internet → Application Load Balancer → ECS Cluster (EC2) → RDS PostgreSQL
                ↓
        Blue/Green Deployment
                ↓
        Auto-scaling Groups
                ↓
        CloudWatch Monitoring
```

### Core Components

- **Frontend**: Flask web application with health checks and database operations
- **Container Orchestration**: Amazon ECS with EC2 launch type
- **Load Balancing**: Application Load Balancer with blue-green deployment support
- **Database**: PostgreSQL RDS instance in private subnets
- **Compute**: Auto-scaling EC2 instances running ECS
- **Networking**: VPC with public/private subnets across multiple AZs
- **Security**: Security groups, IAM roles, and Secrets Manager
- **Monitoring**: CloudWatch alarms, metrics, and dashboards
- **Bastion Host**: EC2 instance for secure SSH access to private resources

## 🚀 Features

- **Blue-Green Deployments**: Zero-downtime deployments with traffic shifting
- **Auto-scaling**: Automatic scaling based on CPU/memory utilization
- **High Availability**: Multi-AZ deployment with health checks
- **Security**: Private subnets, security groups, and IAM roles
- **Monitoring**: Comprehensive CloudWatch monitoring and alerting
- **Infrastructure as Code**: Complete Terraform configuration
- **Containerized**: Docker-based application deployment

## 📁 Project Structure

```
scalable-webapp-ecs-ec2/
├── app/                          # Application source code
│   ├── app.py                   # Flask application
│   └── requirements.txt         # Python dependencies
├── terraform/                   # Infrastructure as Code
│   ├── vpc.tf                  # VPC and networking
│   ├── ecs.tf                  # ECS cluster and services
│   ├── alb.tf                  # Load balancer configuration
│   ├── rds_bastion.tf          # Database and bastion host
│   ├── sg.tf                   # Security groups
│   ├── monitoring.tf           # CloudWatch monitoring
│   ├── variables.tf            # Terraform variables
│   └── outputs.tf              # Output values
├── scripts/                     # Deployment scripts
│   └── canary_shift.sh         # Blue-green traffic shifting
├── Dockerfile                   # Container definition
└── README.md                   # This file
```

## 🛠️ Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform installed (version >= 1.0)
- Docker installed
- SSH key pair for EC2 instances

## 🚀 Quick Start

### 1. Clone and Setup

```bash
git clone <repository-url>
cd scalable-webapp-ecs-ec2
```

### 2. Configure Variables

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

### 3. Deploy Infrastructure

```bash
terraform init
terraform plan
terraform apply
```

### 4. Build and Push Docker Image

```bash
# Get ECR repository URL from terraform output
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <ecr-repo-url>

# Build and push image
docker build -t <ecr-repo-url>:latest .
docker push <ecr-repo-url>:latest
```

### 5. Deploy Application

```bash
# Update ECS service with new image
aws ecs update-service --cluster scalable-webapp-cluster --service prod --force-new-deployment
```

## 🔄 Blue-Green Deployment

The application supports blue-green deployments using the included script:

```bash
# Shift traffic from blue to green (80% green, 20% blue)
./scripts/canary_shift.sh <listener-arn> <blue-tg-arn> <green-tg-arn> 20 80

# Complete shift to green (100% green)
./scripts/canary_shift.sh <listener-arn> <blue-tg-arn> <green-tg-arn> 0 100
```

## 📊 Monitoring

### CloudWatch Alarms

- **ALB 5XX Errors**: Alerts when load balancer returns 5XX errors
- **ECS CPU High**: Alerts when ECS service CPU exceeds 80%
- **RDS CPU High**: Alerts when database CPU exceeds 80%

### CloudWatch Dashboard

Access the dashboard in AWS Console to view:
- Load balancer metrics (5XX errors, response time)
- ECS service metrics (CPU, memory utilization)
- RDS metrics (CPU, free storage space)

## 🔒 Security Features

- **VPC Isolation**: Private subnets for ECS and RDS
- **Security Groups**: Restrictive access rules
- **IAM Roles**: Least privilege access for ECS instances
- **Secrets Manager**: Secure database credentials storage
- **Bastion Host**: Secure SSH access to private resources

## 🌐 Application Endpoints

- **Main Application**: `http://<alb-dns-name>/`
- **Health Check**: `http://<alb-dns-name>/healthz`

## 📈 Scaling

The application automatically scales based on:

- **ECS Service**: Scales based on CPU/memory utilization
- **EC2 Instances**: Auto-scaling group manages container instances
- **Database**: RDS instance can be upgraded for performance

## 🧹 Cleanup

To destroy all resources:

```bash
cd terraform
terraform destroy
```

## 🔧 Configuration

### Key Variables

- `project_name`: Project identifier
- `aws_region`: AWS region for deployment
- `instance_type`: EC2 instance type for ECS
- `asg_min_size`/`asg_max_size`: Auto-scaling group limits
- `db_instance_class`: RDS instance type
- `desired_count_prod`: Number of ECS tasks in production

### Environment Variables

The application expects these environment variables:
- `AWS_REGION`: AWS region
- `DB_SECRET_ARN`: ARN of the database secret in Secrets Manager

## 🐛 Troubleshooting

### Common Issues

1. **ECS Tasks Not Starting**: Check security groups and IAM roles
2. **Database Connection Failed**: Verify Secrets Manager configuration
3. **Load Balancer Health Checks Failing**: Check application health endpoint
4. **Auto-scaling Not Working**: Verify CloudWatch alarms and scaling policies

### Debug Commands

```bash
# Check ECS service status
aws ecs describe-services --cluster scalable-webapp-cluster --services prod

# View ECS task logs
aws logs tail /ecs/scalable-webapp --follow

# Check RDS status
aws rds describe-db-instances --db-instance-identifier <db-id>
```

## 📚 Additional Resources

- [AWS ECS Documentation](https://docs.aws.amazon.com/ecs/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws)
- [Flask Documentation](https://flask.palletsprojects.com/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For issues and questions:
1. Check the troubleshooting section
2. Review CloudWatch logs
3. Open an issue in the repository

---

**Note**: This is a production-ready template. Always review security configurations and adjust based on your specific requirements before deploying to production environments.