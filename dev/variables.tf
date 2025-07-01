variable "environment_name" {
  description = "Name of the environment"
  type        = string
  default     = "dev"
}

variable "availability_zones" {
  type    = list(any)
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}


variable "aws_regions" {
  type    = string
  default = "us-east-1"
}

variable "applications" {
  type = map(object(
    {
      name             = string
      root_volume_size = number
      ami              = string
      instance_type    = string
      availability_zone = string
      subnet_id = string
  }))
  default = {
    "app1" = {
      name              = "app1"
      root_volume_size  = 50
      ami               = "ami-020cba7c55df1f615"
      instance_type     = "t2.micro"
      availability_zone = "us-east-1a"
      subnet_id = "subnet-04f8aa709df9e695d"
    },
    "app2" = {
      name              = "app2"
      root_volume_size  = 50
      ami               = "ami-020cba7c55df1f615"
      instance_type     = "t2.micro"
      availability_zone = "us-east-1b"
      subnet_id = "subnet-008653418e9fa1d49"
    }
  }
}