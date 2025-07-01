variable "aws_regions" {
  type    = string
  default = "us-east-1"
}

variable "environment_name" {
  description = "Name of the environment"
  type        = string
  default     = "dev"
}

variable "availability_zones" {
  type = map(object(
    {
      availability_zone = string
      cidr_block = string
  }))
  default = {
    "1a" = {
      availability_zone = "us-east-1a",
      cidr_block = "10.0.2.0/24"
    },
    "1b" = {
      availability_zone = "us-east-1b",
      cidr_block = "10.0.4.0/24"
    }
  }
}