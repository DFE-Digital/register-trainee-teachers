review:
	echo "setting Review $(env) environment"
	$(eval env_config=review)
	$(eval backend_key=-backend-config=key=$(env).terraform.tfstate)
	$(eval export TF_VAR_paas_app_environment=$(env))


qa:
	$(eval env=qa)
	$(eval env_config=qa)


staging:
	$(eval env=staging)
	$(eval env_config=staging)


production:
	$(if $(CONFIRM_PRODUCTION), , $(error Can only run with CONFIRM_PRODUCTION))
	$(eval env=production)
	$(eval env_config=production)

deploy-plan: terraform-init
	terraform plan -var-file=terraform/workspace-variables/$(env_config).tfvars terraform

deploy: terraform-init
	terraform apply -var-file=terraform/workspace-variables/$(env_config).tfvars -auto-approve terraform

destroy: terraform-init
	terraform destroy -var-file=terraform/workspace-variables/$(env_config).tfvars terraform

terraform-init:
	terraform init -reconfigure -backend-config=terraform/workspace-variables/$(env_config)_backend.tfvars $(backend_key) terraform
	$(if $(tag), , $(error Missing environment variable "tag"))
	$(eval export TF_VAR_paas_app_docker_image=dfedigital/register-trainee-teacher-data:$(tag))
	$(if $(passcode), , $(error Missing environment variable "passcode"))
	$(eval export TF_VAR_paas_sso_passcode=$(passcode))
