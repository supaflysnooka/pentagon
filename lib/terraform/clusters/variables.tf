variable "utility_subnet_bits" {
  default = 8
}

variable "private_subnet_bits" {
  default = 10
}

variable "cluster_subnet_bits" {}
variable "cluster_subnets" {
  type = "list"
}
variable "cluster_names" {
  type = "list"
}

variable "nat_gateway_ids" {
  type = "list"
}

variable "availability_zones" {
  type = "list"
}

variable "infrastructure_name" {}

variable "hosted_zone_name" {}

variable "vpc_id" {}

variable "master_count" {}
variable "node_count" {}
variable "kops_state_store_bucket" {}
