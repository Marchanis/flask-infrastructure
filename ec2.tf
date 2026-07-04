resource "aws_instance" "bastion" {
    ami           = "ami-0c02fb55956c7d316" 
    instance_type = "t3.micro"
    subnet_id     = aws_subnet.public_1a.id
    key_name      = "my-key"
    vpc_security_group_ids = [aws_security_group.bastion_sg.id]
    associate_public_ip_address = true

    tags = {
        Name = "flask-bastion"
    }
  
} 

resource "aws_launch_template" "flask_ec2_lt" {
    name          = "flask-ec2-lt"
    image_id      = var.ami_id
    instance_type = var.instance_type
    key_name      = var.key_name
    vpc_security_group_ids = [aws_security_group.ec2_sg.id]
    iam_instance_profile {
        name = aws_iam_instance_profile.ec2_instance_profile.name
    }
    user_data = base64encode(<<-EOF
                #!/bin/bash
                export TERM=xterm-256color
                yum update -y
                yum install -y docker git aws-cli
                systemctl start docker
                systemctl enable docker
                usermod -aG docker ec2-user
                mkdir -p /usr/local/lib/docker/cli-plugins
                curl -L "https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-linux-x86_64" -o /usr/local/lib/docker/cli-plugins/docker-compose
                chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
                cd /home/ec2-user
                git clone https://github.com/Marchanis/flask-ec2-app.git
                cd flask-ec2-app

                # Pull secrets from SSM and create .env file
                echo "DB_HOST=$(aws ssm get-parameter --name '/flask-app/DB_HOST' --with-decryption --query Parameter.Value --output text --region us-east-1)" > .env
                echo "DB_NAME=$(aws ssm get-parameter --name '/flask-app/DB_NAME' --with-decryption --query Parameter.Value --output text --region us-east-1)" >> .env
                echo "DB_USER=$(aws ssm get-parameter --name '/flask-app/DB_USER' --with-decryption --query Parameter.Value --output text --region us-east-1)" >> .env
                echo "DB_PASSWORD=$(aws ssm get-parameter --name '/flask-app/DB_PASSWORD' --with-decryption --query Parameter.Value --output text --region us-east-1)" >> .env

                docker compose up -d
        EOF
    )   

    lifecycle {
        create_before_destroy = true
    }

    tags = {
        Name = "flask-ec2-lt"
    }
}

resource "aws_autoscaling_group" "flask_ec2_asg" {
    desired_capacity     = var.desired_capacity
    max_size             = 3
    min_size             = 1
    target_group_arns    = [aws_alb_target_group.flask_tg.arn]
    vpc_zone_identifier  = [aws_subnet.private_ec2_1a.id, aws_subnet.private_ec2_1b.id]
    instance_refresh {
        strategy = "Rolling"
        preferences {
            min_healthy_percentage = 50
            instance_warmup        = 300
        }
    }
    launch_template {
        id      = aws_launch_template.flask_ec2_lt.id
        version = "$Latest"
    }

    tag {
        key                 = "Name"
        value               = "flask-ec2-asg"
        propagate_at_launch = true
    }
}





