resource "aws_ssm_parameter" "db_host" {
  name  = "/flask-app/DB_HOST"
  type  = "String"
  value = aws_db_instance.flask_db.address
}

resource "aws_ssm_parameter" "db_name" {
  name  = "/flask-app/DB_NAME"
  type  = "String"
  value = aws_db_instance.flask_db.db_name
}

resource "aws_ssm_parameter" "db_user" {
  name  = "/flask-app/DB_USER"
  type  = "String"
  value = aws_db_instance.flask_db.username
}

resource "aws_ssm_parameter" "db_password" {
  name  = "/flask-app/DB_PASSWORD"
  type  = "SecureString"
  value = aws_db_instance.flask_db.password
}