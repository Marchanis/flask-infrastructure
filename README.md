# Flask AWS Infrastructure

Production-grade AWS infrastructure built entirely with Terraform. Deploys a containerized Flask application with high availability, private networking, automated scaling, and secure secret management

## Architecture
<img width="2720" height="2960" alt="flask_vpc_architecture" src="https://github.com/user-attachments/assets/e7bb5a9d-bc0a-4d5e-b833-45aaa803fd04" />

## Services Used

VPC — Creates an isolated private network in AWS. Public subnets expose only the ALB to the internet while EC2 and RDS stay in private subnets, unreachable from outside.
EC2 — Runs the containerized Flask application inside private subnets, managed by an Auto Scaling Group that automatically launches or terminates instances based on demand.
RDS PostgreSQL — Managed relational database in a private subnet. Only EC2 instances can connect to it via security group rules — never exposed to the internet.
IAM — Grants EC2 instances permission to read secrets from SSM Parameter Store and interact with AWS services — no hardcoded credentials needed.
S3 — Stores the Terraform state file remotely so the entire team shares the same infrastructure state.
ALB — Receives all incoming HTTP traffic and distributes it across healthy EC2 instances. The only resource with a public-facing endpoint.
ASG — Automatically maintains the desired number of EC2 instances. Replaces unhealthy instances and scales up under load.
SSM Parameter Store — Stores database credentials securely encrypted. EC2 instances pull secrets at launch time — no .env files in GitHub.

## Infrastructure Overview
(describe VPC, subnets, security)

## Security
(how secrets are handled, private subnets, bastion)

## Remote State
(S3 + DynamoDB)

## How to Deploy
(prerequisites + commands)

## How to Destroy
