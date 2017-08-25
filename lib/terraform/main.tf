// Sample main.tf

provider "aws" {
  region     = "${var.aws_region}"
}

module "vpc" {
  source                        = "./vpc"
  aws_vpc_name                  = "${var.infrastructure_name}"
  aws_region                    = "${var.aws_region}"

  az_count                      = "${length(var.aws_azs)}"
  aws_azs                       = "${join(", ",var.aws_azs)}"

  vpc_cidr_base                 = "${var.vpc_cidr}"

  admin_subnet_cidrs            = "${data.null_data_source.admin_subnet.*.outputs.cidr}"
  public_subnet_cidrs           = "${data.null_data_source.public_subnet.*.outputs.cidr}"
  private_prod_subnet_cidrs     = "${data.null_data_source.private_production_subnet.*.outputs.cidr}"
  private_working_subnet_cidrs  = "${data.null_data_source.private_working_subnet.*.outputs.cidr}"
}

module "clusters" {
  source                  = "./clusters"

  clusters_path           = "${template_dir.project_config.destination_dir}/vpc/${var.infrastructure_name}/clusters"
  cluster_names           = "${var.cluster_names}"
  cluster_subnets         = "${data.null_data_source.cluster_subnet.*.outputs.cidr}"
  cluster_subnet_bits     = "${var.k8s_subnet_bits}"
  utility_subnet_bits     = 8
  private_subnet_bits     = 10
  vpc_id                  = "${module.vpc.aws_vpc_id}"
  hosted_zone_name        = "${var.aws_hosted_zone_name}"
  infrastructure_name     = "${var.infrastructure_name}"
  kops_state_store_bucket = "${var.infrastructure_name}-kops"
  nat_gateway_ids         = "${concat(module.vpc.aws_nat_gateway_ids, list("", "", ""))}"
  availability_zones      = "${concat(var.aws_azs, list("", "", ""))}"
  node_count              = "${var.node_count}"
  master_count            = "${var.master_count}"
}

resource "aws_s3_bucket" "kops_state_store" {
  bucket = "${var.infrastructure_name}-kops"
  acl    = "private"

  versioning {
    enabled = true
  }
}

// terraform backend config

terraform {
  backend "s3" {}
}
