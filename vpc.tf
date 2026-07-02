resource "aws_vpc" "flask_vpc" {
    enable_dns_hostnames = true
    tags = {
        Name = "flask-vpc"
    }
    cidr_block = var.vpc_cidr
}

resource "aws_subnet" "public_1a" {
    vpc_id = aws_vpc.flask_vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"

    tags = {
        Name = "flask-public-1a"
    }
}

resource "aws_subnet" "public_1b" {
    vpc_id = aws_vpc.flask_vpc.id
    cidr_block = "10.0.2.0/24"  
    availability_zone = "us-east-1b"

    tags = {
        Name = "flask-public-1b"
    }
}

resource "aws_subnet" "private_ec2_1a" {
    vpc_id = aws_vpc.flask_vpc.id
    cidr_block = "10.0.3.0/24"
    availability_zone = "us-east-1a"

    tags = {
        Name = "flask-private-ec2-1a"
    }
}

resource "aws_subnet" "private_ec2_1b" {
    vpc_id = aws_vpc.flask_vpc.id
    cidr_block = "10.0.4.0/24"
    availability_zone = "us-east-1b"

    tags = {
        Name = "flask-private-ec2-1b"
    }
}   

resource "aws_subnet" "private_rds_1a" {
    vpc_id = aws_vpc.flask_vpc.id
    cidr_block = "10.0.5.0/24"
    availability_zone = "us-east-1a"    

    tags = {
        Name = "flask-private-rds-1a"
    }
}

resource "aws_subnet" "private_rds_1b" {
    vpc_id = aws_vpc.flask_vpc.id
    cidr_block = "10.0.6.0/24"
    availability_zone = "us-east-1b"

    tags = {
        Name = "flask-private-rds-1b"
    }
}

resource "aws_internet_gateway" "flask_igw" {
    vpc_id = aws_vpc.flask_vpc.id

    tags = {
        Name = "flask-igw"
    }
}

resource "aws_route_table" "flask_public_rt" {
    vpc_id = aws_vpc.flask_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.flask_igw.id
    }

    tags = {
        Name = "flask-public-rt"
    }
}

resource "aws_route_table_association" "public_1a" {
    subnet_id      = aws_subnet.public_1a.id
    route_table_id = aws_route_table.flask_public_rt.id
}

resource "aws_route_table_association" "public_1b" {
    subnet_id      = aws_subnet.public_1b.id
    route_table_id = aws_route_table.flask_public_rt.id
}

resource "aws_eip" "vpc_nat_eip" {
    domain = "vpc"
}

resource "aws_nat_gateway" "flask_nat_gw" {
    allocation_id = aws_eip.vpc_nat_eip.id
    subnet_id     = aws_subnet.public_1a.id
    depends_on = [aws_internet_gateway.flask_igw] #Don't even start creating this NAT Gateway until the Internet Gateway is fully built
    

    tags = {
        Name = "flask-nat-gw"
    }
}

resource "aws_route_table" "flask_private_rt" {
    vpc_id = aws_vpc.flask_vpc.id

    route {
        cidr_block     = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.flask_nat_gw.id
    } 
    tags = {
        Name = "flask-private-rt"
    }
}

resource "aws_route_table_association" "private_ec2_1a" {
    subnet_id      = aws_subnet.private_ec2_1a.id
    route_table_id = aws_route_table.flask_private_rt.id
}

resource "aws_route_table_association" "private_ec2_1b" {
    subnet_id      = aws_subnet.private_ec2_1b.id
    route_table_id = aws_route_table.flask_private_rt.id
}

resource "aws_route_table_association" "private_rds_1a" {
    subnet_id      = aws_subnet.private_rds_1a.id
    route_table_id = aws_route_table.flask_private_rt.id
}

resource "aws_route_table_association" "private_rds_1b" {
    subnet_id      = aws_subnet.private_rds_1b.id
    route_table_id = aws_route_table.flask_private_rt.id
}
