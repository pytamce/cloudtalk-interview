resource "aws_kms_key" "ec2" {
  description             = "KMS key"
  deletion_window_in_days = 10
  tags = {
    Name        = var.environment_name
    }
}
data "aws_security_group" "bastion_sg" {
  name = "private-ec2-sg"
}

data "template_file" "user_data" {
  template = file("${path.module}/some_user_data.sh")
  vars = {
    ENVIRONMENT = var.environment_name
  }
}

resource "aws_instance" "web" {
  instance_type = var.instance_type
  ami           = var.ami
  subnet_id     = var.subnet_id
  vpc_security_group_ids = [data.aws_security_group.bastion_sg.id]
  monitoring    = false
  disable_api_termination = false
  key_name = var.environment_name
  user_data = data.template_file.user_data.rendered
  root_block_device {
    volume_type = var.volume_type
    volume_size = var.volume_size
    encrypted = true
    kms_key_id = aws_kms_key.ec2.arn
  }
  tags = {
    Name        = var.name
    Environment = var.environment_name
    Region      = var.aws_regions
  }
}
