data "template_file" "cluster_yaml" {
  count = "${length(var.cluster_names)}"
  template = "${file("${path.module}/resources/cluster.yaml")}"

  vars {
    kops_cluster_name = "cluster_name"
    kops_state_store_bucket = "state_store_bucket"
    aws_hosted_zone_name = "zone.name"
    kubernetes_version = "1.5.7"
    aws_vpc_id = "vpc_id"
    subnet_yaml = "${join("", list(
      element(data.template_file.utility_subnet_yaml_a.*.rendered, count.index),
      element(data.template_file.utility_subnet_yaml_b.*.rendered, count.index),
      element(data.template_file.utility_subnet_yaml_c.*.rendered, count.index),
      length(compact(var.availability_zones)) > 3 ? element(data.template_file.utility_subnet_yaml_c.*.rendered, count.index) : "",
      element(data.template_file.private_subnet_yaml_a.*.rendered, count.index),
      element(data.template_file.private_subnet_yaml_b.*.rendered, count.index),
      element(data.template_file.private_subnet_yaml_c.*.rendered, count.index),
      length(compact(var.availability_zones)) > 3 ? element(data.template_file.private_subnet_yaml_c.*.rendered, count.index) : "",
    ))}"
  }
}

resource "local_file" "cluster_yaml" {
  count = "${length(var.cluster_names)}"

  content = "${element(data.template_file.cluster_yaml.*.rendered, count.index)}"
  filename = "/tmp/cluster-${count.index}.yaml"
}
