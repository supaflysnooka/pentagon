# Variables set here are not necessarily available as environment variables in your shell.
# To add any, modify the appropriate list in env-vars.sh

export KOPS_STATE_STORE_BUCKET="${kops_state_store_bucket}"
export KOPS_STATE_STORE="s3://$KOPS_STATE_STORE_BUCKET"

# export VPC_NAME: "{{ vpc_name }}"
#
# export AWS_DEFAULT_REGION:  "{{ aws_default_region }}"
# export AWS_AVAILABILITY_ZONES: "{{ aws_availability_zones }}"
# export AWS_AVAILABILITY_ZONE_COUNT: "{{ aws_availability_zone_count }}"
#
# export ANSIBLE_CONFIG: '$INFRASTRUCTURE_REPO/config/private/ansible.cfg'
# export KUBECONFIG: '$INFRASTRUCTURE_REPO/config/private/kube_config'
# export AWS_INVENTORY_PATH: '$INFRASTRUCTURE_REPO/plugins/'
#
# export INFRASTRUCTURE_BUCKET: "{{ infrastructure_bucket }}"
