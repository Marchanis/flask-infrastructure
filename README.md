# Flask AWS Infrastructure

> Production-grade AWS infrastructure built entirely with Terraform. Deploys a containerized Flask application with high availability, private networking, automated scaling, and secure secret management.

---

## Architecture

<img width="800" alt="flask_vpc_architecture" src="https://github.com/user-attachments/assets/e7bb5a9d-bc0a-4d5e-b833-45aaa803fd04" />

---

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

---

## Infrastructure Overview

### Network

- **VPC** — `10.0.0.0/16` isolated private network in `us-east-1`
- **6 subnets** across 2 availability zones (`us-east-1a`, `us-east-1b`)
  - 2 public subnets — ALB and NAT Gateway
  - 2 private subnets — EC2 instances
  - 2 private subnets — RDS PostgreSQL

### Security Groups

| Resource | Inbound Port | Source |
|----------|-------------|--------|
| ALB | 80, 443 | `0.0.0.0/0` (internet) |
| EC2 | 80 | ALB security group only |
| EC2 | 22 | Bastion security group only |
| RDS | 5432 | EC2 security group only |
| Bastion | 22 | Your IP only (`/32`) |

### Traffic Flow

```
Internet → ALB (public subnet) → EC2 (private subnet) → RDS (private subnet)
```

> Private EC2 instances reach the internet for updates via NAT Gateway — but cannot be reached from the internet directly.

---

## Security

### Secret Management

- Database credentials stored in **AWS SSM Parameter Store** — encrypted, never in code
- EC2 instances pull secrets at launch time via User Data — no `.env` files committed to GitHub
- Sensitive Terraform values stored in `terraform.tfvars` — listed in `.gitignore`

### Private Networking

- EC2 instances live in private subnets — no public IP, unreachable from the internet
- RDS lives in private subnets — only accessible from EC2 via security group rules
- Private instances reach the internet for updates via **NAT Gateway** — one-way outbound only

### Bastion Host

- Single entry point into the private network
- Lives in a public subnet with a public IP
- SSH access restricted to **your IP only** via security group
- Flow: `Your device → Bastion (public subnet) → EC2 (private subnet)`

### Zero-Trust Security Group Chain

```
Internet  →  ALB only
ALB       →  EC2 on port 80 only
Bastion   →  EC2 on port 22 only
EC2       →  RDS on port 5432 only
```

> Nothing talks to anything unless explicitly allowed.

---

## Remote State

Terraform state is stored remotely in S3 — not on a local machine.

| Resource | Purpose |
|----------|---------|
| **S3 bucket** | `flask-terraform-state-sal` — stores state file, shared across the team |
| **S3 versioning** | Enabled — every state change is saved, allows rollback if state gets corrupted |
| **DynamoDB table** | `flask-terraform-locks` — locks state during `terraform apply`, prevents two engineers from applying simultaneously |

### Why remote state matters

- Local state lives on one laptop — teammates can't access it
- If the laptop is lost or wiped, the state is gone forever
- Without locking, two simultaneous `apply` runs corrupt the state file

---

## How to Deploy

### Prerequisites

- AWS CLI configured (`aws configure`)
- Terraform >= 1.0.0 installed
- AWS IAM user with appropriate permissions
- SSH key pair created in `us-east-1` named `my-key`

### Steps

**1. Clone the repository**
```bash
git clone https://github.com/Marchanis/flask-infrastructure.git
cd flask-infrastructure
```

**2. Create your `terraform.tfvars` file**
```hcl
db_username = "your-db-username"
db_password = "your-db-password"
```

**3. Initialize Terraform and configure remote state**
```bash
terraform init
```

**4. Review what will be created**
```bash
terraform plan
```

**5. Deploy the infrastructure**
```bash
terraform apply
```

After apply completes, copy the ALB DNS name from the outputs and open it in your browser.

---

## How to Destroy

Always destroy when done to avoid unnecessary AWS costs.

> ⚠️ **NAT Gateway costs $0.045/hr** — always destroy when not actively learning or testing.

```bash
terraform destroy
```

> **Warning:** This deletes all infrastructure including the database. Data will be lost.

---

## Author

Built by [@Marchanis](https://github.com/Marchanis) as part of a hands-on AWS Cloud Engineering learning path.
