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

data "aws_subnet" "app_private_subnet_1" {
  filter {
    name   = "tag:Name"
    values = ["app-subnet-us-east-1a-private"]
  }
}

data "aws_subnet" "app_private_subnet_2" {
  filter {
    name   = "tag:Name"
    values = ["app-subnet-us-east-1b-private"]
  }
}

locals {
  apps_with_subnets = {
    app1 = merge(var.applications["app1"], {
      subnet_id = data.aws_subnet.app_private_subnet_1.id
    })
    app2 = merge(var.applications["app2"], {
      subnet_id = data.aws_subnet.app_private_subnet_2.id
    })
  }
}


module "applications" {
  source            = "../modules/application"
  for_each          = local.apps_with_subnets
  instance_type     = each.value.instance_type
  ami               = each.value.ami
  volume_size       = each.value.root_volume_size
  name              = "${each.key}-${var.environment_name}-${var.aws_regions}"
  availability_zone = each.value.availability_zone
  subnet_id         = each.value.subnet_id
}
