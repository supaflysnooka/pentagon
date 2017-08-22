// Always generate subnet information for maximum supported AZs so we don't
// have to destructively rearrange them later.

data "null_data_source" "utility_subnet_a" {
  count = 4
  inputs {
    cidr = "${cidrsubnet(var.cluster_subnet, var.cluster_subnet_bits - var.utility_subnet_bits, count.index)}"
  }
}

data "null_data_source" "private_subnet" {
  count = 4
  inputs {
    cidr = "${cidrsubnet(var.cluster_subnet, var.cluster_subnet_bits - var.private_subnet_bits, count.index + data.null_data_source.private_start.outputs["index"])}"
  }
}

data "null_data_source" "private_start" {
  inputs {
    index = "${ceil(4 / pow(2, var.private_subnet_bits - var.utility_subnet_bits))}"
  }
}

resource "local_file" "public" {
  content = <<EOF
${join(",", data.null_data_source.private_subnet.*.outputs.cidr)}
EOF
  filename = "/tmp/debug2.txt"
}
