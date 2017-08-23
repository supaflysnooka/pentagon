data "template_file" "instancegroup_master_a" {
  count = "${length(var.cluster_names)}"
  template = "${file("${path.module}/resources/instancegroup.yaml")}"

  vars {
    name              = "master-${var.availability_zones[0]}"
    kops_cluster_name = "${var.cluster_names[count.index]}.${var.hosted_zone_name}"
    ec2_flavor        = "t2.medium"
    role              = "Master"
    max_size          = "${var.master_count > 0 ? 1 : 0}"
    min_size          = "${var.master_count > 0 ? 1 : 0}"
    subnets           = "  - ${var.availability_zones[0]}"
  }
}

data "template_file" "instancegroup_master_b" {
  count = "${length(var.cluster_names)}"
  template = "${file("${path.module}/resources/instancegroup.yaml")}"

  vars {
    name              = "master-${var.availability_zones[1]}"
    kops_cluster_name = "${var.cluster_names[count.index]}.${var.hosted_zone_name}"
    ec2_flavor        = "t2.medium"
    role              = "Master"
    max_size          = "${var.master_count > 1 ? 1 : 0}"
    min_size          = "${var.master_count > 1 ? 1 : 0}"
    subnets           = "  - ${var.availability_zones[1]}"
  }
}

data "template_file" "instancegroup_master_c" {
  count = "${length(var.cluster_names)}"
  template = "${file("${path.module}/resources/instancegroup.yaml")}"

  vars {
    name              = "master-${var.availability_zones[2]}"
    kops_cluster_name = "${var.cluster_names[count.index]}.${var.hosted_zone_name}"
    ec2_flavor        = "t2.medium"
    role              = "Master"
    max_size          = "${var.master_count > 2 ? 1 : 0}"
    min_size          = "${var.master_count > 2 ? 1 : 0}"
    subnets           = "  - ${var.availability_zones[2]}"
  }
}

data "template_file" "instancegroup_master_d" {
  count = "${length(var.cluster_names)}"
  template = "${file("${path.module}/resources/instancegroup.yaml")}"

  vars {
    name              = "master-${var.availability_zones[3]}"
    kops_cluster_name = "${var.cluster_names[count.index]}.${var.hosted_zone_name}"
    ec2_flavor        = "t2.medium"
    role              = "Master"
    max_size          = "${var.master_count > 3 ? 1 : 0}"
    min_size          = "${var.master_count > 3 ? 1 : 0}"
    subnets           = "  - ${var.availability_zones[3]}"
  }
}

data "template_file" "instancegroup_nodes" {
  count = "${length(var.cluster_names)}"
  template = "${file("${path.module}/resources/instancegroup.yaml")}"

  vars {
    name              = "nodes"
    kops_cluster_name = "${var.cluster_names[count.index]}.${var.hosted_zone_name}"
    ec2_flavor        = "t2.medium"
    role              = "Node"
    max_size          = "${var.node_count}"
    min_size          = "${var.node_count}"
    subnets           = <<EOF
  - ${var.availability_zones[0]}
  - ${var.availability_zones[1]}
  - ${var.availability_zones[2]}
    ${length(compact(var.availability_zones)) > 3 ? "- var.availability_zones[3]" : ""}
EOF
  }
}

data "template_file" "etcdmember" {
  count = "${var.master_count}"
  template = <<EOF
    - instanceGroup: $${id}
      name: $${name}
EOF

  vars = {
    id    = "master-${var.availability_zones[count.index]}"
    name  = "${substr(var.availability_zones[count.index], -1, 1)}"
  }
}
