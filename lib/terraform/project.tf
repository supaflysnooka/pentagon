resource "template_dir" "project_config" {
  source_dir      = "${path.module}/project-template"
  destination_dir = "${path.cwd}/${var.infrastructure_name}-infrastructure"

  vars {
    vpc_name                 = "${var.infrastructure_name}"
    org_name                 = "${var.infrastructure_name}"
    aws_key_name             = "TBD"
    vpn_ami_id               = "TBD"
    dns_zone                 = "${var.aws_hosted_zone_name}"
    kops_state_store_bucket  = "${var.infrastructure_name}-kops"
  }
}
