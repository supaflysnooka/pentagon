.PHONY: all init plan apply destroy clean

all: plan apply

BUCKET_NAME = $(shell cat terraform.tfvars | grep infrastructure_name | awk '{print $$3}' | tr -d '"')

init:
	cd backend && terraform init; \
	AWS_DEFAULT_REGION=us-east-1 terraform apply \
		-state-out=backend.tfstate -var-file ../terraform.tfvars

	terraform init \
	  -backend=true \
		-backend-config="bucket=$(BUCKET_NAME)-terraform" \
		-backend-config="key=pentagon/tf.state" \
		-backend-config="region=us-east-1"

plan:
	terraform plan -var-file terraform.tfvars

apply:
	terraform apply -var-file terraform.tfvars

destroy:
	terraform plan -destroy -var-file terraform.tfvars -out terraform.tfplan
	terraform apply terraform.tfplan

clean:
	rm -f terraform.tfplan
	rm -fR .terraform/
