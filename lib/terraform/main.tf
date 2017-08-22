// Sample main.tf

provider "aws" {
  region     = "${var.aws_region}"
}

module "vpc" {
  source                             = "./vpc"
  aws_vpc_name                       = "${var.aws_vpc_name}"
  aws_region                         = "${var.aws_region}"

  az_count                           = "${length(var.aws_azs)}"
  aws_azs                            = "${join(",",var.aws_azs)}"

  vpc_cidr_base                      = "${var.vpc_cidr}"

  admin_subnet_cidrs                 = "${data.null_data_source.admin_subnet.*.outputs.cidr}"
  public_subnet_cidrs                = "${data.null_data_source.public_subnet.*.outputs.cidr}"
  private_prod_subnet_cidrs          = "${data.null_data_source.private_production_subnet.*.outputs.cidr}"
  private_working_subnet_cidrs       = "${data.null_data_source.private_working_subnet.*.outputs.cidr}"
}

module "clusters" {
  source                             = "./clusters"

  cluster_names                      = "${var.cluster_names}"
  cluster_subnets                    = "${data.null_data_source.cluster_subnet.*.outputs.cidr}"
  cluster_subnet_bits                = "${var.k8s_subnet_bits}"
  utility_subnet_bits                = 8
  private_subnet_bits                = 10
  # nat_gateway_ids                    = "${module.vpc.aws_nat_gateway_ids}"
  nat_gateway_ids                    = ["1", "2", "3", "4"]
  availability_zones                 = "${concat(var.aws_azs, list("", "", ""))}"
}

resource "local_file" "public" {
  content = "${join(",", data.null_data_source.cluster_subnet.*.outputs.cidr)}"
  filename = "/tmp/debug.txt"
}

// terraform backend config

# terraform {
#  backend "s3" {}
# }
