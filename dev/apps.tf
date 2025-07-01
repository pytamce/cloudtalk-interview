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
  default_tags {
    tags = {
      Environment = var.environment_name

    }
  }
}


module "applications" {
  source            = "../modules/application"
  for_each          = var.applications
  instance_type     = each.value.instance_type
  ami               = each.value.ami
  volume_size       = each.value.root_volume_size
  name              = "${each.key}-${var.environment_name}-${var.aws_regions}"
  availability_zone = each.value.availability_zone
  subnet_id         = each.value.subnet_id
}
