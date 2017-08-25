data "template_file" "cluster_yaml" {
  count     = "${length(var.cluster_names)}"
  template  = "${file("${path.module}/resources/cluster.yaml")}"

  vars {
    kops_cluster_name         = "${var.cluster_names[count.index]}.${var.hosted_zone_name}"
    kops_state_store_bucket   = "${var.kops_state_store_bucket}"
    aws_hosted_zone_name      = "${var.hosted_zone_name}"
    kubernetes_version        = "1.5.7"
    aws_vpc_id                = "${var.vpc_id}"
    subnet_yaml               = "${join("", list(
      element(data.template_file.subnet_yaml_a.*.rendered, count.index),
      element(data.template_file.subnet_yaml_b.*.rendered, count.index),
      element(data.template_file.subnet_yaml_c.*.rendered, count.index),
      length(compact(var.availability_zones)) > 3 ? element(data.template_file.subnet_yaml_d.*.rendered, count.index) : "",
    ))}"
    instancegroups            = "${join("", list(
      element(data.template_file.instancegroup_master_a.*.rendered, count.index),
      element(data.template_file.instancegroup_master_b.*.rendered, count.index),
      element(data.template_file.instancegroup_master_c.*.rendered, count.index),
      length(compact(var.availability_zones)) > 3 ? element(data.template_file.instancegroup_master_d.*.rendered, count.index) : "",
      element(data.template_file.instancegroup_nodes.*.rendered, count.index),
    ))}"
    etcdmembers               = "${join("", data.template_file.etcdmember.*.rendered)}"
  }
}

resource "local_file" "cluster_yaml" {
  count       = "${length(var.cluster_names)}"

  content     = "${element(data.template_file.cluster_yaml.*.rendered, count.index)}"
  filename    = "${var.clusters_path}/${var.cluster_names[count.index]}/cluster.yaml"
}
