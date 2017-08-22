null_resource "subnet" {
  count = "${length(var.cluster_names)}"
  triggers {

  }
}
