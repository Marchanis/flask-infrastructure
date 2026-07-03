# Flask AWS Infrastructure

Production-grade AWS infrastructure built entirely with Terraform. Deploys a 
containerized Flask application with high availability, private networking, 
automated scaling, and secure secret management.

## Architecture
<img width="2720" height="2960" alt="flask_vpc_architecture" src="https://github.com/user-attachments/assets/e7bb5a9d-bc0a-4d5e-b833-45aaa803fd04" />

## Services Used


| Service | Purpose |
|---------|---------|
| **VPC** | Isolated private network. Public subnets expose only the ALB — EC2 and RDS stay unreachable from the internet |
| **ALB** | Receives all incoming HTTP traffic and distributes it across healthy EC2 instances. The only public-facing endpoint |
| **EC2 + ASG** | Runs the containerized Flask app in private subnets. ASG automatically replaces unhealthy instances and scales under load |
| **RDS PostgreSQL** | Managed database in a private subnet. Only EC2 can connect via security group rules — never exposed to the internet |
| **IAM** | Grants EC2 permission to read secrets from SSM — no hardcoded credentials anywhere |
| **SSM Parameter Store** | Stores database credentials encrypted. EC2 pulls secrets at launch time — no `.env` files in GitHub |
| **S3** | Stores Terraform state file remotely so the whole team shares the same infrastructure state |
| **DynamoDB** | Locks the state file during `terraform apply` — prevents two engineers from applying at the same time |


## Infrastructure Overview
(describe VPC, subnets, security)

## Security
(how secrets are handled, private subnets, bastion)

## Remote State
(S3 + DynamoDB)

## How to Deploy
(prerequisites + commands)

## How to Destroy
