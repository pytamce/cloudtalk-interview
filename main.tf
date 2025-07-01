terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0.0"
    }
  }
}

provider "aws" {
  region = var.aws_regions
}

data "http" "my_ip" {
  url = "https://ipv4.icanhazip.com"
}

resource "tls_private_key" "ec2_martin_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "martin_key" {
  key_name   = var.environment_name
  public_key = tls_private_key.ec2_martin_key.public_key_openssh
}


resource "local_file" "private_key_pem" {
  content         = tls_private_key.ec2_martin_key.private_key_pem
  filename        = "${path.module}/${var.environment_name}.pem"
  file_permission = "0600"
}

resource "aws_vpc" "app-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "app-vpc"
  }
}

resource "aws_subnet" "app-public-subnet" {
  vpc_id                  = aws_vpc.app-vpc.id
  cidr_block              = "10.0.20.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "app-public-subnet"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.app-vpc.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.app-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.app-public-subnet.id
  route_table_id = aws_route_table.public.id
}

resource "aws_subnet" "app-private-subnet" {
  for_each          = var.availability_zones
  vpc_id            = aws_vpc.app-vpc.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone
  tags = {
    Name = "app-subnet-${each.value.availability_zone}-private"
  }
}

resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  description = "Allow SSH from your IP"
  vpc_id      = aws_vpc.app-vpc.id

  ingress {
    description = "SSH from your IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.my_ip.response_body)}/32"]
    #cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "private_ec2_sg" {
  name        = "private-ec2-sg"
  description = "Allow SSH from bastion"
  vpc_id      = aws_vpc.app-vpc.id

  ingress {
    description = "SSH from Bastion Host"
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

resource "aws_instance" "bastion" {
  ami                         = "ami-020cba7c55df1f615"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.app-public-subnet.id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.martin_key.key_name
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  tags = {
    Name = "Bastion Host"
  }
  user_data = <<-EOF
              #!/bin/bash
              cat <<EOT > /home/ubuntu/dev.pem
              ${tls_private_key.ec2_martin_key.private_key_pem}
              EOT
              chown ubuntu:ubuntu /home/ubuntu/dev.pem
              chmod 400 /home/ubuntu/dev.pem
              EOF
  depends_on = [
    local_file.private_key_pem
  ]
}




