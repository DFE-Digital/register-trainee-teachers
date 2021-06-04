ifndef VERBOSE
.SILENT:
endif

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
	$(eval export TF_VAR_paas_app_environment=review)
	$(eval export TF_VAR_paas_web_app_hostname=pr-$(env))
	$(eval space=bat-qa)
	$(eval AZ_SUBSCRIPTION=s121-findpostgraduateteachertraining-development)

audit:
	$(eval env=audit)
	$(eval env_config=audit)
	$(eval space=bat-qa)
	$(eval AZ_SUBSCRIPTION=s121-findpostgraduateteachertraining-development)


local: ## Configure local dev environment
	$(eval env=local)
	$(eval AZ_SUBSCRIPTION=s121-findpostgraduateteachertraining-development)

qa:
	$(eval env=qa)
	$(eval env_config=qa)
	$(eval space=bat-qa)
	$(eval AZ_SUBSCRIPTION=s121-findpostgraduateteachertraining-development)

staging:
	$(eval env=staging)
	$(eval env_config=staging)
	$(eval space=bat-staging)
	$(eval AZ_SUBSCRIPTION=s121-findpostgraduateteachertraining-test)

production:
	$(if $(CONFIRM_PRODUCTION), , $(error Can only run with CONFIRM_PRODUCTION))
	$(eval env=production)
	$(eval env_config=production)
	$(eval space=bat-prod)
	$(eval AZ_SUBSCRIPTION=s121-findpostgraduateteachertraining-production)

sandbox:
	$(eval env=sandbox)
	$(eval env_config=sandbox)
	$(eval space=bat-prod)
	$(eval AZ_SUBSCRIPTION=s121-findpostgraduateteachertraining-production)

rollover:
	$(eval env=rollover)
	$(eval env_config=rollover)
	$(eval space=bat-staging)
	$(eval AZ_SUBSCRIPTION=s121-findpostgraduateteachertraining-test)

install-fetch-config:
	[ ! -f bin/fetch_config.rb ] \
		&& curl -s https://raw.githubusercontent.com/DFE-Digital/bat-platform-building-blocks/master/scripts/fetch_config/fetch_config.rb -o bin/fetch_config.rb \
		&& chmod +x bin/fetch_config.rb \
		|| true

set-azure-account:
	az account set -s ${AZ_SUBSCRIPTION}

edit-app-secrets: install-fetch-config set-azure-account
	. terraform/workspace-variables/$(env_config).sh && bin/fetch_config.rb -s azure-key-vault-secret:$${TF_VAR_key_vault_name}/$${TF_VAR_key_vault_app_secret_name} \
		-e -d azure-key-vault-secret:$${TF_VAR_key_vault_name}/$${TF_VAR_key_vault_app_secret_name} -f yaml -c

edit-infra-secrets: install-fetch-config set-azure-account
	. terraform/workspace-variables/$(env_config).sh && bin/fetch_config.rb -s azure-key-vault-secret:$${TF_VAR_key_vault_name}/$${TF_VAR_key_vault_infra_secret_name} \
		-e -d azure-key-vault-secret:$${TF_VAR_key_vault_name}/$${TF_VAR_key_vault_infra_secret_name} -f yaml -c

print-app-secrets: install-fetch-config set-azure-account
	. terraform/workspace-variables/$(env_config).sh && bin/fetch_config.rb -s azure-key-vault-secret:$${TF_VAR_key_vault_name}/$${TF_VAR_key_vault_app_secret_name} \
		-f yaml

print-infra-secrets: install-fetch-config set-azure-account
	. terraform/workspace-variables/$(env_config).sh && bin/fetch_config.rb -s azure-key-vault-secret:$${TF_VAR_key_vault_name}/$${TF_VAR_key_vault_infra_secret_name} \
		-f yaml

deploy-plan: terraform-init
	. terraform/workspace-variables/$(env_config).sh && cd terraform && terraform plan -var-file=workspace-variables/$(env_config).tfvars

deploy: terraform-init
	. terraform/workspace-variables/$(env_config).sh && cd terraform &&  terraform apply -var-file=workspace-variables/$(env_config).tfvars -auto-approve

destroy: terraform-init
	cd terraform && terraform destroy -var-file=workspace-variables/$(env_config).tfvars

terraform-init:
	$(if $(tag), , $(eval export tag=master))
	$(eval export TF_VAR_paas_app_docker_image=dfedigital/register-trainee-teachers:$(tag))
	$(if $(passcode), , $(error Missing environment variable "passcode", retrieve from https://login.london.cloud.service.gov.uk/passcode))
	$(eval export TF_VAR_paas_sso_passcode=$(passcode))
	az account set -s $(AZ_SUBSCRIPTION) && az account show \
	&& cd terraform && terraform init -reconfigure -backend-config=workspace-variables/$(env_config)_backend.tfvars $(backend_key)


console:
	cf target -s ${space}
	cf ssh register-${env} -t -c "cd /app && /usr/local/bin/bundle exec rails c"
