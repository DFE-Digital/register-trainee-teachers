help:
	@echo "Environment setup targets:"
	@echo "  review     - configure for review app"
	@echo "  qa"
	@echo "  staging"
	@echo "  production"
	@echo ""
	@echo "Commands:"
	@echo "  deploy-plan - Print out the plan for the deploy, does not deploy."
	@echo ""
	@echo "Command Options:"
	@echo "      env      - name of the environment being setup, set this when creating review apps"
	@echo "      tag      - git sha of a built image, see builds in GitHub Actions"
	@echo "      passcode - your authentication code for GOVUK PaaS, retrieve from"
	@echo "                 https://login.london.cloud.service.gov.uk/passcode"
	@echo ""
	@echo "Examples:"
	@echo "  Create a review app"
	@echo "    You will need to retrieve the authentication code from GOVUK PaaS"
	@echo "    visit https://login.london.cloud.service.gov.uk/passcode. Then run"
	@echo "    deploy-plan to test:"
	@echo ""
	@echo "        make review env=REVIEW_APP_NAME deploy-plan tag=GIT_REF passcode=AUTHCODE"

review:
	echo "setting Review $(env) environment"
	$(eval env_config=review)
	$(eval backend_key=-backend-config=key=$(env).terraform.tfstate)
	$(eval export TF_VAR_paas_app_environment=$(env))

pentest:
	echo "setting Review $(env) environment"
	$(eval env_config=pen)
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

console:
	cf target -s bat-${env}
	cf ssh register-${env} -t -c "cd /app && /usr/local/bin/bundle exec rails c"
