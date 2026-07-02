resource "aws_security_group" "alb_sg" {
    name        = "alb-sg"
    description = "Security group for ALB"
    vpc_id      = aws_vpc.flask_vpc.id

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]   
  
}

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "ec2_sg" {
    name        = "ec2-sg"
    description = "Security group for EC2 instances"
    vpc_id      = aws_vpc.flask_vpc.id

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        security_groups = [aws_security_group.alb_sg.id]
    }
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        security_groups = [aws_security_group.bastion_sg.id]
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "bastion_sg" {
    name        = "bastion-sg"
    description = "Security group for Bastion host"
    vpc_id      = aws_vpc.flask_vpc.id

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["196.117.208.85/32"]
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "rds_sg" {
    name        = "rds-sg"
    description = "Security group for RDS"
    vpc_id      = aws_vpc.flask_vpc.id

    ingress {
        from_port   = 5432
        to_port     = 5432
        protocol    = "tcp"
        security_groups = [aws_security_group.ec2_sg.id]
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

