// Always generate subnet information for maximum supported AZs so we don't
// have to destructively rearrange them later.

// The subnets are created iteratively

// First the admin subnets
data "null_data_source" "admin_subnet" {
  count = 4
  inputs {
    cidr = "${cidrsubnet("172.20.0.0/16", 16 - var.admin_subnet_bits, count.index)}"
  }
}

// Then the public subnets starts right after the admin subnets
data "null_data_source" "public_start" {
  inputs {
    index = "${ceil(4 / pow(2, var.public_subnet_bits - var.admin_subnet_bits))}"
  }
}

data "null_data_source" "public_subnet" {
  count = 4
  inputs {
    cidr = "${cidrsubnet("172.20.0.0/16", 16 - var.public_subnet_bits, count.index + data.null_data_source.public_start.outputs["index"])}"
  }
}

// Then the private production subnets start right after the public subnets
data "null_data_source" "private_production_start" {
  inputs {
    index = "${ceil((4 + data.null_data_source.public_start.outputs["index"]) / pow(2, var.private_production_subnet_bits - var.public_subnet_bits))}"
  }
}

data "null_data_source" "private_production_subnet" {
  count = 4
  inputs {
    cidr = "${cidrsubnet("172.20.0.0/16", 16 - var.private_production_subnet_bits, count.index + data.null_data_source.private_production_start.outputs["index"])}"
  }
}

// Then the private working subnets start right after the private production subnets
data "null_data_source" "private_working_start" {
  inputs {
    index = "${ceil((4 + data.null_data_source.private_production_start.outputs["index"]) / pow(2, var.private_working_subnet_bits - var.private_production_subnet_bits))}"
  }
}

data "null_data_source" "private_working_subnet" {
  count = 4
  inputs {
    cidr = "${cidrsubnet("172.20.0.0/16", 16 - var.private_working_subnet_bits, count.index + data.null_data_source.private_working_start.outputs["index"])}"
  }
}

// Then we calculate the cidrs that will contain each Kubernetes cluster's subnets starting right after the private working subnets
data "null_data_source" "cluster_subnets_start" {
  inputs {
    index = "${ceil((4 + data.null_data_source.private_working_start.outputs["index"]) / pow(2, var.k8s_subnet_bits - var.private_working_subnet_bits))}"
  }
}

data "null_data_source" "cluster_subnet" {
  count = "${length(var.cluster_names)}"
  inputs {
    cidr = "${cidrsubnet("172.20.0.0/16", 16 - var.k8s_subnet_bits, count.index + data.null_data_source.cluster_subnets_start.outputs["index"])}"
  }
}
