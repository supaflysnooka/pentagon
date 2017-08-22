variable "utility_subnet_bits" {
  default = 8
}

variable "private_subnet_bits" {
  default = 10
}

variable "cluster_subnet_bits" {}
variable "cluster_subnet" {}
variable "cluster_name" {
  type = "list"
}

variable "nat_gateway_ids" {}
