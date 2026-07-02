resource "aws_db_subnet_group" "flask_db_subnet_group" {
    name       = "flask-db-subnet-group"
    subnet_ids = [aws_subnet.private_rds_1a.id, aws_subnet.private_rds_1b.id]

    tags = {
        Name = "flask-db-subnet-group"
    }
  
}


resource "aws_db_instance" "flask_db" {
    identifier              = "flask-db"
    allocated_storage       = var.db_allocated_storage
    engine                  = var.db_engine
    engine_version          = var.db_engine_version
    instance_class          = var.db_instance_class
    username                = var.db_username
    password                = var.db_password
    db_subnet_group_name    = aws_db_subnet_group.flask_db_subnet_group.name
    vpc_security_group_ids  = [aws_security_group.rds_sg.id]
    publicly_accessible     = false
    skip_final_snapshot     = true
    db_name                 = "flaskdb"

    tags = {
        Name = "flask-db"
    }
}