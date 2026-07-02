variable "db_password" {
  description = "RDS master password"
  type = string
  sensitive = true
}

variable "db_username" {
  description = "RDS master username"
  type = string
  sensitive = true
}

variable "region" {
  description = "AWS region"
  type = string
  default = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type = string
  default = "10.0.0.0/16"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instances"
  type = string
  default = "ami-0c02fb55956c7d316" # Amazon Linux 2 AMI
}

variable "instance_type" {
  description = "EC2 instance type"
  type = string
  default = "t3.micro"
}

variable "key_name" {
  description = "Key pair name for SSH access"
  type = string
  default = "my-key"
}

variable "desired_capacity" {
  description = "Desired number of EC2 instances in the Auto Scaling group"
  type = number
  default = 2
}

variable "db_instance_class" {
  description = "RDS instance type"
  type = string
  default = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Allocated storage for the RDS instance (in GB)"
  type = number
  default = 20
}

variable "db_engine" {
  description = "Database engine for RDS"
  type = string
  default = "postgres"
}

variable "db_engine_version" {
  description = "Database engine version for RDS"
  type = string
  default = "15.7"
}