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

variable "name" {
  type    = string
}

variable "volume_size" {
  type    = number
}

variable "ami" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "volume_type" {
  type = string
  default = "gp3"
}

variable "availability_zone" {
  type = string
}

variable "subnet_id" {
  type = string
}