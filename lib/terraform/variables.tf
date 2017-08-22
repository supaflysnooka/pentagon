variable "cluster_names" {
  type = "list"
  default = ["working-1", "production-1"]
}

###
# AWS account specific variables
###

variable "aws_region" {
  default = "us-east-1"
}

variable "aws_azs" {
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
  type = "list"
}

variable "aws_hosted_zone_name" {}

###
# Organization specific variables
###

variable "vpc_cidr" {
  default = "172.20"
}

variable "aws_vpc_name" {}

variable "admin_subnet_bits" {
  default = 7
}

variable "public_subnet_bits" {
  default = 8
}

variable "private_production_subnet_bits" {
  default = 8
}

variable "private_working_subnet_bits" {
  default = 8
}

variable "k8s_utility_subnet_bits" {
  default = 8
}

variable "k8s_private_subnet_bits" {
  default = 8
}

variable "k8s_subnet_bits" {
  default = 13
}
