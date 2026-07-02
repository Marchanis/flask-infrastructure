resource "aws_iam_role" "ec2_role" {
    name = "flask-ec2-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    Service = "ec2.amazonaws.com"
                }
            }
        ]
    })
  
}

resource "aws_iam_role_policy_attachment" "aws_iam_role_policy_attachment" {
    role       = aws_iam_role.ec2_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
    name = "flask-ec2-instance-profile"
    role = aws_iam_role.ec2_role.name
}