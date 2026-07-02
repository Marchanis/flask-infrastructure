resource "aws_alb" "flask_alb" {
    name            = "flask-alb"
    internal        = false
    security_groups = [aws_security_group.alb_sg.id]
    subnets         = [aws_subnet.public_1a.id, aws_subnet.public_1b.id]
    load_balancer_type = "application"

    tags = {
        Name = "flask-alb"
    }
  
}

resource "aws_alb_target_group" "flask_tg" {
    name     = "flask-tg"
    port     = 80
    protocol = "HTTP"
    vpc_id   = aws_vpc.flask_vpc.id
    

    health_check {
        path                = "/"
        interval            = 30
        timeout             = 5
        healthy_threshold   = 2
        unhealthy_threshold = 2
        matcher             = "200-399"
    }

    tags = {
        Name = "flask-tg"
    }
}

resource "aws_alb_listener" "flask_listener" {
    load_balancer_arn = aws_alb.flask_alb.arn
    port              = 80
    protocol          = "HTTP"

    default_action {
        type             = "forward"
        target_group_arn = aws_alb_target_group.flask_tg.arn
    }
}