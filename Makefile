ifndef VERBOSE
.SILENT:
endif
SERVICE_SHORT=rtt
SERVICE_NAME=register

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
	@echo "      APP_NAME  - name of the app being setup, required only for review apps"
	@echo "      IMAGE_TAG - git sha of a built image, see builds in GitHub Actions"
	@echo ""
	@echo "Examples:"
	@echo "  Create a review app"
	@echo "  Run deploy-plan to test:"
	@echo ""
	@echo "        make review APP_NAME=pr-PR_NUMBER deploy-plan IMAGE_TAG=GIT_REF"

.PHONY: install-konduit
install-konduit: ## Install the konduit script, for accessing backend services
	[ ! -f bin/konduit.sh ] \
		&& curl -s https://raw.githubusercontent.com/DFE-Digital/teacher-services-cloud/master/scripts/konduit.sh -o bin/konduit.sh \
		&& chmod +x bin/konduit.sh \
		|| true

local: ## Configure local dev environment
	$(eval DEPLOY_ENV=local)
	$(eval AZ_SUBSCRIPTION=s121-findpostgraduateteachertraining-development)

ci:	## Run in automation environment
	$(eval export AUTO_APPROVE=-auto-approve)
	$(eval SKIP_CONFIRM=true)

review:
	$(if $(APP_NAME), , $(error Missing environment variable "APP_NAME", Please specify a pr number for your review app))
	$(eval include global_config/review.sh)
	$(eval DEPLOY_ENV=review)
	$(eval export TF_VAR_app_name=$(APP_NAME))
	$(eval backend_key=-backend-config=key=$(APP_NAME).tfstate)
	$(eval export TF_VARS=-var config_short=${CONFIG_SHORT} -var service_short=${SERVICE_SHORT} -var service_name=${SERVICE_NAME} -var azure_resource_prefix=${RESOURCE_NAME_PREFIX})
	echo https://register-$(APP_NAME).test.teacherservices.cloud will be created in aks

dv_review: ## make dv_review deploy APP_NAME=2222 CLUSTER=cluster1
	$(if $(APP_NAME), , $(error Missing environment variable "APP_NAME", Please specify a pr number for your review app))
	$(if $(CLUSTER), , $(error Missing environment variable "CLUSTER", Please specify a dev cluster name (eg 'cluster1')))
	$(eval include global_config/dv_review.sh)
	$(eval DEPLOY_ENV=dv_review)
	$(eval backend_key=-backend-config=key=$(APP_NAME).tfstate)
	$(eval export TF_VAR_cluster=$(CLUSTER))
	$(eval export TF_VAR_app_name=$(APP_NAME))
	$(eval export TF_VARS=-var config_short=${CONFIG_SHORT} -var service_short=${SERVICE_SHORT} -var service_name=${SERVICE_NAME} -var azure_resource_prefix=${RESOURCE_NAME_PREFIX})
	echo https://register-$(APP_NAME).$(CLUSTER).development.teacherservices.cloud will be created in aks

qa:
	$(eval include global_config/qa.sh)
	$(eval DEPLOY_ENV=qa)
	$(eval BACKUP_CONTAINER_NAME=qa-db-backup)
	$(eval export TF_VARS=-var config_short=${CONFIG_SHORT} -var service_short=${SERVICE_SHORT} -var service_name=${SERVICE_NAME} -var azure_resource_prefix=${RESOURCE_NAME_PREFIX})

staging:
	$(eval include global_config/staging.sh)
	$(eval DEPLOY_ENV=staging)
	$(eval export TF_VARS=-var config_short=${CONFIG_SHORT} -var service_short=${SERVICE_SHORT} -var service_name=${SERVICE_NAME} -var azure_resource_prefix=${RESOURCE_NAME_PREFIX})

production:
	$(eval include global_config/production.sh)
	$(if $(or ${SKIP_CONFIRM}, ${CONFIRM_PRODUCTION}), , $(error Missing CONFIRM_PRODUCTION=yes))
	$(eval DEPLOY_ENV=production)
	$(eval HOST_NAME=www)
	$(eval BACKUP_CONTAINER_NAME=prod-db-backup)
	$(eval export TF_VARS=-var config_short=${CONFIG_SHORT} -var service_short=${SERVICE_SHORT} -var service_name=${SERVICE_NAME} -var azure_resource_prefix=${RESOURCE_NAME_PREFIX})

productiondata:
	$(eval include global_config/productiondata.sh)
	$(if $(or ${SKIP_CONFIRM}, ${CONFIRM_PRODUCTION}), , $(error Missing CONFIRM_PRODUCTION=yes))
	$(eval DEPLOY_ENV=productiondata)
	$(eval export TF_VARS=-var config_short=${CONFIG_SHORT} -var service_short=${SERVICE_SHORT} -var service_name=${SERVICE_NAME} -var azure_resource_prefix=${RESOURCE_NAME_PREFIX})

csv-sandbox:
	$(eval include global_config/csv-sandbox.sh)
	$(if $(or ${SKIP_CONFIRM}, ${CONFIRM_PRODUCTION}), , $(error Missing CONFIRM_PRODUCTION=yes))
	$(eval DEPLOY_ENV=csv-sandbox)
	$(eval export TF_VARS=-var config_short=${CONFIG_SHORT} -var service_short=${SERVICE_SHORT} -var service_name=${SERVICE_NAME} -var azure_resource_prefix=${RESOURCE_NAME_PREFIX})

sandbox:
	$(eval include global_config/sandbox.sh)
	$(eval DEPLOY_ENV=sandbox)
	$(eval export TF_VARS=-var config_short=${CONFIG_SHORT} -var service_short=${SERVICE_SHORT} -var service_name=${SERVICE_NAME} -var azure_resource_prefix=${RESOURCE_NAME_PREFIX})

set-azure-account:
	echo "Logging on to ${AZ_SUBSCRIPTION}"
	az account set -s ${AZ_SUBSCRIPTION}

set-what-if:
	$(eval WHAT_IF=--what-if)

set-azure-resource-group-tags: ##Tags that will be added to resource group on its creation in ARM template
	$(eval RG_TAGS=$(shell echo '{"Portfolio": "Early Years and Schools Group", "Parent Business":"Teacher Training and Qualifications", "Product" : "Register trainee teachers", "Service Line": "Teaching Workforce", "Service": "Teacher services", "Service Offering": "Teacher services cloud", "Environment" : "$(ENV_TAG)"}' | jq . ))

set-azure-template-tag:
	$(eval ARM_TEMPLATE_TAG=1.1.0)

arm-deployment: set-azure-account set-azure-template-tag set-azure-resource-group-tags
	az deployment sub create --name "resourcedeploy-tsc-$(shell date +%Y%m%d%H%M%S)" \
		-l "UK South" --template-uri "https://raw.githubusercontent.com/DFE-Digital/tra-shared-services/${ARM_TEMPLATE_TAG}/azure/resourcedeploy.json" \
		--parameters "resourceGroupName=${RESOURCE_NAME_PREFIX}-${SERVICE_SHORT}-${CONFIG_SHORT}-rg" 'tags=${RG_TAGS}' \
			"tfStorageAccountName=${RESOURCE_NAME_PREFIX}${SERVICE_SHORT}tfstate${CONFIG_SHORT}sa" "tfStorageContainerName=${SERVICE_SHORT}-tfstate" \
			"keyVaultName=${RESOURCE_NAME_PREFIX}-${SERVICE_SHORT}-${CONFIG_SHORT}-kv" ${WHAT_IF}

deploy-arm-resources: arm-deployment ## Validate ARM resource deployment. Usage: make domains validate-arm-resources

validate-arm-resources: set-what-if arm-deployment ## Validate ARM resource deployment. Usage: make domains validate-arm-resources

install-fetch-config:
	[ ! -f bin/fetch_config.rb ] \
		&& curl -s https://raw.githubusercontent.com/DFE-Digital/bat-platform-building-blocks/master/scripts/fetch_config/fetch_config.rb -o bin/fetch_config.rb \
		&& chmod +x bin/fetch_config.rb \
		|| true

read-tf-config:
	$(eval key_vault_name=$(shell jq -r '.key_vault_name' terraform/$(PLATFORM)/workspace-variables/$(DEPLOY_ENV).tfvars.json))
	$(eval key_vault_app_secret_name=$(shell jq -r '.key_vault_app_secret_name' terraform/$(PLATFORM)/workspace-variables/$(DEPLOY_ENV).tfvars.json))
	$(eval key_vault_infra_secret_name=$(shell jq -r '.key_vault_infra_secret_name' terraform/$(PLATFORM)/workspace-variables/$(DEPLOY_ENV).tfvars.json))

read-cluster-config:
	$(eval CLUSTER=$(shell jq -r '.cluster' terraform/$(PLATFORM)/workspace-variables/$(DEPLOY_ENV).tfvars.json))
	$(eval NAMESPACE=$(shell jq -r '.namespace' terraform/$(PLATFORM)/workspace-variables/$(DEPLOY_ENV).tfvars.json))
	$(eval CONFIG_LONG=$(shell jq -r '.env_config' terraform/$(PLATFORM)/workspace-variables/$(DEPLOY_ENV).tfvars.json))

edit-app-secrets: read-tf-config install-fetch-config set-azure-account
	bin/fetch_config.rb -s azure-key-vault-secret:${key_vault_name}/${key_vault_app_secret_name} \
		-e -d azure-key-vault-secret:${key_vault_name}/${key_vault_app_secret_name} -f yaml -c

edit-infra-secrets: read-tf-config install-fetch-config set-azure-account
	bin/fetch_config.rb -s azure-key-vault-secret:${key_vault_name}/${key_vault_infra_secret_name} \
		-e -d azure-key-vault-secret:${key_vault_name}/${key_vault_infra_secret_name} -f yaml -c

print-app-secrets: read-tf-config install-fetch-config set-azure-account
	bin/fetch_config.rb -s azure-key-vault-secret:${key_vault_name}/${key_vault_app_secret_name} -f yaml

print-infra-secrets: read-tf-config install-fetch-config set-azure-account
	bin/fetch_config.rb -s azure-key-vault-secret:${key_vault_name}/${key_vault_infra_secret_name} -f yaml

deploy-plan: terraform-init
	terraform -chdir=terraform/$(PLATFORM) plan -var-file=./workspace-variables/$(DEPLOY_ENV).tfvars.json -var-file=./workspace-variables/$(DEPLOY_ENV)_backend.tfvars ${TF_VARS}

deploy: terraform-init
	terraform -chdir=terraform/$(PLATFORM) apply -var-file=./workspace-variables/$(DEPLOY_ENV).tfvars.json -var-file=./workspace-variables/$(DEPLOY_ENV)_backend.tfvars ${TF_VARS} $(AUTO_APPROVE)

destroy: terraform-init
	terraform -chdir=terraform/$(PLATFORM) destroy -var-file=./workspace-variables/$(DEPLOY_ENV).tfvars.json -var-file=./workspace-variables/$(DEPLOY_ENV)_backend.tfvars ${TF_VARS} $(AUTO_APPROVE)

terraform-init:
	$(if $(IMAGE_TAG), , $(eval export IMAGE_TAG=main))
	$(eval export TF_VAR_app_docker_image=ghcr.io/dfe-digital/register-trainee-teachers:$(IMAGE_TAG))

	az account set -s $(AZ_SUBSCRIPTION) && az account show
	rm -rf terraform/$(PLATFORM)/vendor/modules/aks
	git -c advice.detachedHead=false clone --depth=1 --single-branch --branch ${TERRAFORM_MODULES_TAG} https://github.com/DFE-Digital/terraform-modules.git terraform/$(PLATFORM)/vendor/modules/aks
	terraform -chdir=terraform/$(PLATFORM) init -reconfigure -upgrade -backend-config=./workspace-variables/$(DEPLOY_ENV)_backend.tfvars $(backend_key)

get-cluster-credentials: read-cluster-config set-azure-account ## make <config> get-cluster-credentials [ENVIRONMENT=<clusterX>]
	az aks get-credentials --overwrite-existing -g ${RESOURCE_NAME_PREFIX}-tsc-${CLUSTER_SHORT}-rg -n ${RESOURCE_NAME_PREFIX}-tsc-${CLUSTER}-aks
	kubelogin convert-kubeconfig -l $(if ${AAD_LOGIN_METHOD},${AAD_LOGIN_METHOD},azurecli)

console: get-cluster-credentials
	$(if $(APP_NAME), $(eval export APP_ID=$(APP_NAME)) , $(eval export APP_ID=$(CONFIG_LONG)))
	kubectl -n ${NAMESPACE} exec -ti --tty deployment/register-${APP_ID} -- /bin/sh -c "cd /app && /usr/local/bin/bundle exec rails c"

logs: get-cluster-credentials
	$(if $(APP_NAME), $(eval export APP_ID=$(APP_NAME)) , $(eval export APP_ID=$(CONFIG_LONG)))
	kubectl -n ${NAMESPACE} logs -l app=register-${APP_ID} --tail=-1 --timestamps=true

worker-logs: get-cluster-credentials
	$(if $(APP_NAME), $(eval export APP_ID=$(APP_NAME)) , $(eval export APP_ID=$(CONFIG_LONG)))
	kubectl -n ${NAMESPACE} logs -l app=register-${APP_ID}-worker --tail=-1 --timestamps=true

ssh: get-cluster-credentials
	$(if $(APP_NAME), $(eval export APP_ID=$(APP_NAME)) , $(eval export APP_ID=$(CONFIG_LONG)))
	kubectl -n ${NAMESPACE} exec -ti --tty deployment/register-${APP_ID} -- /bin/sh

worker-ssh: get-cluster-credentials
	$(if $(APP_NAME), $(eval export APP_ID=$(APP_NAME)) , $(eval export APP_ID=$(CONFIG_LONG)))
	kubectl -n ${NAMESPACE} exec -ti --tty deployment/register-${APP_ID}-worker -- /bin/sh

domains:
	$(eval include global_config/register-domain.sh)

domains-infra-init: domains set-azure-account
	rm -rf terraform/custom_domains/infrastructure/vendor/modules/domains
	git -c advice.detachedHead=false clone --depth=1 --single-branch --branch ${TERRAFORM_MODULES_TAG} https://github.com/DFE-Digital/terraform-modules.git terraform/custom_domains/infrastructure/vendor/modules/domains

	terraform -chdir=terraform/custom_domains/infrastructure init -reconfigure -upgrade \
		-backend-config=workspace_variables/${DOMAINS_ID}_backend.tfvars

domains-infra-plan: domains-infra-init # make domains-infra-plan
	terraform -chdir=terraform/custom_domains/infrastructure plan -var-file workspace_variables/${DOMAINS_ID}.tfvars.json

domains-infra-apply: domains-infra-init # make domains-infra-apply
	terraform -chdir=terraform/custom_domains/infrastructure apply -var-file workspace_variables/${DOMAINS_ID}.tfvars.json ${AUTO_APPROVE}

domains-init: domains set-azure-account
	rm -rf terraform/custom_domains/environment_domains/vendor/modules/domains
	git -c advice.detachedHead=false clone --depth=1 --single-branch --branch ${TERRAFORM_MODULES_TAG} https://github.com/DFE-Digital/terraform-modules.git terraform/custom_domains/environment_domains/vendor/modules/domains

	terraform -chdir=terraform/custom_domains/environment_domains init -upgrade -reconfigure -backend-config=workspace_variables/${DOMAINS_ID}_${DEPLOY_ENV}_backend.tfvars

domains-plan: domains-init  # make qa domains-plan
	terraform -chdir=terraform/custom_domains/environment_domains plan -var-file workspace_variables/${DOMAINS_ID}_${DEPLOY_ENV}.tfvars.json

domains-apply: domains-init # make qa domains-apply
	terraform -chdir=terraform/custom_domains/environment_domains apply -var-file workspace_variables/${DOMAINS_ID}_${DEPLOY_ENV}.tfvars.json ${AUTO_APPROVE}

domains-destroy: domains-init # make qa domains-destroy
	terraform -chdir=terraform/custom_domains/environment_domains destroy -var-file workspace_variables/${DOMAINS_ID}_${DEPLOY_ENV}.tfvars.json

domain-azure-resources: domains set-azure-account set-azure-template-tag set-azure-resource-group-tags # make domain-azure-resources
	az deployment sub create -l "UK South" --template-uri "https://raw.githubusercontent.com/DFE-Digital/tra-shared-services/${ARM_TEMPLATE_TAG}/azure/resourcedeploy.json" \
		--name "${DNS_ZONE}domains-$(shell date +%Y%m%d%H%M%S)" --parameters "resourceGroupName=${RESOURCE_NAME_PREFIX}-${DNS_ZONE}domains-rg" 'tags=${RG_TAGS}' \
			"tfStorageAccountName=${RESOURCE_NAME_PREFIX}${DNS_ZONE}domainstf" "tfStorageContainerName=${DNS_ZONE}domains-tf"  "keyVaultName=${RESOURCE_NAME_PREFIX}-${DNS_ZONE}domains-kv" ${WHAT_IF}

validate-domain-resources: set-what-if domain-azure-resources # make validate-domain-resources

action-group-resources: set-azure-account # make env action-group-resources ACTION_GROUP_EMAIL=notificationemail@domain.com . Must be run before setting enable_monitoring=true for each subscription
	$(if $(ACTION_GROUP_EMAIL), , $(error Please specify a notification email for the action group))
	echo ${RESOURCE_NAME_PREFIX}-${SERVICE_SHORT}-mn-rg
	az group create -l uksouth -g ${RESOURCE_NAME_PREFIX}-${SERVICE_SHORT}-mn-rg --tags "Product=Register trainee teachers" "Environment=Test" "Service Offering=Teacher services cloud"
	az monitor action-group create -n ${RESOURCE_NAME_PREFIX}-${SERVICE_NAME} -g ${RESOURCE_NAME_PREFIX}-${SERVICE_SHORT}-mn-rg --action email ${RESOURCE_NAME_PREFIX}-${SERVICE_SHORT}-email ${ACTION_GROUP_EMAIL}

maintenance-image-push:
	$(if ${GITHUB_TOKEN},, $(error Provide a valid Github token with write:packages permissions as GITHUB_TOKEN variable))
	$(if ${MAINTENANCE_IMAGE_TAG},, $(eval export MAINTENANCE_IMAGE_TAG=$(shell date +%s)))
	docker build -t ghcr.io/dfe-digital/register-maintenance:${MAINTENANCE_IMAGE_TAG} maintenance_page
	echo ${GITHUB_TOKEN} | docker login ghcr.io -u USERNAME --password-stdin
	docker push ghcr.io/dfe-digital/register-maintenance:${MAINTENANCE_IMAGE_TAG}

maintenance-fail-over: get-cluster-credentials
	$(eval export CONFIG)
	./maintenance_page/scripts/failover.sh

enable-maintenance: maintenance-image-push maintenance-fail-over

disable-maintenance: get-cluster-credentials
	$(eval export CONFIG)
	./maintenance_page/scripts/failback.sh
