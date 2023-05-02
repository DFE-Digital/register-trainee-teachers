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
	@echo "      PASSCODE  - your authentication code for GOVUK PaaS, retrieve from"
	@echo "                  https://login.london.cloud.service.gov.uk/passcode"
	@echo ""
	@echo "Examples:"
	@echo "  Create a review app"
	@echo "    You will need to retrieve the authentication code from GOVUK PaaS"
	@echo "    visit https://login.london.cloud.service.gov.uk/passcode. Then run"
	@echo "    deploy-plan to test:"
	@echo ""
	@echo "        make review APP_NAME=pr-PR_NUMBER deploy-plan IMAGE_TAG=GIT_REF PASSCODE=AUTHCODE"

.PHONY: install-konduit
install-konduit: ## Install the konduit script, for accessing backend services
	[ ! -f bin/konduit.sh ] \
		&& curl -s https://raw.githubusercontent.com/DFE-Digital/teacher-services-cloud/master/scripts/konduit.sh -o bin/konduit.sh \
		&& chmod +x bin/konduit.sh \
		|| true

.PHONY: review
review:
	$(if $(APP_NAME), , $(error Missing environment variable "APP_NAME", Please specify a name for your review app))
	$(eval DEPLOY_ENV=review)
	$(eval backend_key=-backend-config=key=$(APP_NAME).tfstate)
	$(eval export TF_VAR_paas_app_name=$(APP_NAME))
	$(eval export TF_VAR_app_suffix=$(paas_env))
	$(eval export TF_VAR_azure_resource_group_name=s121d01-reg-rv-$(APP_NAME)-rg)
	$(eval export TF_VAR_azure_tempdata_storage_account_name=s121d01regrv$(subst -,,$(APP_NAME)))
	$(eval AZ_SUBSCRIPTION=s121-findpostgraduateteachertraining-development)
	$(eval space=bat-qa)
	$(eval paas_env=pr-$(APP_NAME))
	$(eval BACKUP_CONTAINER_NAME=pr-$(APP_NAME)-db-backup)
	$(eval PLATFORM=paas)
	echo https://register-$(APP_NAME).london.cloudapps.digital will be created in bat-qa space

local: ## Configure local dev environment
	$(eval DEPLOY_ENV=local)
	$(eval AZ_SUBSCRIPTION=s121-findpostgraduateteachertraining-development)

ci:	## Run in automation environment
	$(eval export DISABLE_PASSCODE=true)
	$(eval export AUTO_APPROVE=-auto-approve)

qa:
	$(eval DEPLOY_ENV=qa)
	$(eval AZ_SUBSCRIPTION=s121-findpostgraduateteachertraining-development)
	$(eval DTTP_HOSTNAME=traineeteacherportal-dv)
	$(eval space=bat-qa)
	$(eval paas_env=qa)
	$(eval BACKUP_CONTAINER_NAME=qa-db-backup)
	$(eval PLATFORM=paas)

staging:
	$(eval DEPLOY_ENV=staging)
	$(eval AZ_SUBSCRIPTION=s121-findpostgraduateteachertraining-test)
	$(eval DTTP_HOSTNAME=traineeteacherportal-pp)
	$(eval PLATFORM=paas)

pen:
	$(eval DEPLOY_ENV=pen)
	$(eval AZ_SUBSCRIPTION=s121-findpostgraduateteachertraining-test)
	$(eval DTTP_HOSTNAME=traineeteacherportal-pp)

audit:
	$(eval DEPLOY_ENV=audit)

production:
	$(if $(CONFIRM_PRODUCTION), , $(error Can only run with CONFIRM_PRODUCTION))
	$(eval DEPLOY_ENV=production)
	$(eval AZ_SUBSCRIPTION=s121-findpostgraduateteachertraining-production)
	$(eval HOST_NAME=www)
	$(eval DTTP_HOSTNAME=traineeteacherportal)
	$(eval paas_env=production)
	$(eval BACKUP_CONTAINER_NAME=prod-db-backup)
	$(eval PLATFORM=paas)

productiondata:
	$(if $(CONFIRM_PRODUCTION), , $(error Can only run with CONFIRM_PRODUCTION))
	$(eval DEPLOY_ENV=productiondata)
	$(eval AZ_SUBSCRIPTION=s121-findpostgraduateteachertraining-production)
	$(eval PLATFORM=paas)

review_aks:
	$(if $(APP_NAME), , $(error Missing environment variable "APP_NAME", Please specify a pr number for your review app))
	$(eval include global_config/review_aks.sh)
	$(eval DEPLOY_ENV=review_aks)
	$(eval export TF_VAR_app_name=$(APP_NAME))
	$(eval backend_key=-backend-config=key=$(APP_NAME).tfstate)
	$(eval export TF_VARS=-var config_short=${CONFIG_SHORT} -var service_short=${SERVICE_SHORT} -var service_name=${SERVICE_NAME} -var azure_resource_prefix=${RESOURCE_NAME_PREFIX})
	echo https://register-$(APP_NAME).test.teacherservices.cloud will be created in aks
#	$(eval export TF_VAR_azure_resource_group_name=s121d01-reg-rv-$(APP_NAME)-rg)
#	$(eval export TF_VAR_azure_tempdata_storage_account_name=s121d01regrv$(subst -,,$(APP_NAME)))

dv_review_aks: ## make dv_review_aks deploy APP_NAME=2222 CLUSTER=cluster1
	$(if $(APP_NAME), , $(error Missing environment variable "APP_NAME", Please specify a pr number for your review app))
	$(if $(CLUSTER), , $(error Missing environment variable "CLUSTER", Please specify a dev cluster name (eg 'cluster1')))
	$(eval include global_config/dv_review_aks.sh)
	$(eval DEPLOY_ENV=dv_review_aks)
	$(eval backend_key=-backend-config=key=$(APP_NAME).tfstate)
	$(eval export TF_VAR_cluster=$(CLUSTER))
	$(eval export TF_VAR_app_name=$(APP_NAME))
	$(eval export TF_VARS=-var config_short=${CONFIG_SHORT} -var service_short=${SERVICE_SHORT} -var service_name=${SERVICE_NAME} -var azure_resource_prefix=${RESOURCE_NAME_PREFIX})
	echo https://register-$(APP_NAME).$(CLUSTER).development.teacherservices.cloud will be created in aks

qa_aks:
	$(eval include global_config/qa_aks.sh)
	$(eval DEPLOY_ENV=qa_aks)
	$(eval DTTP_HOSTNAME=traineeteacherportal-dv)
	$(eval paas_env=qa)
	$(eval BACKUP_CONTAINER_NAME=qa-db-backup)
	$(eval export TF_VARS=-var config_short=${CONFIG_SHORT} -var service_short=${SERVICE_SHORT} -var service_name=${SERVICE_NAME} -var azure_resource_prefix=${RESOURCE_NAME_PREFIX})

staging_aks:
	$(eval include global_config/staging_aks.sh)
	$(eval DEPLOY_ENV=staging_aks)
	$(eval DTTP_HOSTNAME=traineeteacherportal-pp)
	$(eval export TF_VARS=-var config_short=${CONFIG_SHORT} -var service_short=${SERVICE_SHORT} -var service_name=${SERVICE_NAME} -var azure_resource_prefix=${RESOURCE_NAME_PREFIX})

production_aks:
	$(eval include global_config/production_aks.sh)
	$(if $(CONFIRM_PRODUCTION), , $(error Can only run with CONFIRM_PRODUCTION))
	$(eval DEPLOY_ENV=production_aks)
	$(eval HOST_NAME=www)
	$(eval DTTP_HOSTNAME=traineeteacherportal)
	$(eval paas_env=production)
	$(eval BACKUP_CONTAINER_NAME=prod-db-backup)
	$(eval export TF_VARS=-var config_short=${CONFIG_SHORT} -var service_short=${SERVICE_SHORT} -var service_name=${SERVICE_NAME} -var azure_resource_prefix=${RESOURCE_NAME_PREFIX})

productiondata_aks:
	$(eval include global_config/productiondata_aks.sh)
	$(if $(CONFIRM_PRODUCTION), , $(error Can only run with CONFIRM_PRODUCTION))
	$(eval DEPLOY_ENV=productiondata_aks)
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

install-fetch-config:
	[ ! -f bin/fetch_config.rb ] \
		&& curl -s https://raw.githubusercontent.com/DFE-Digital/bat-platform-building-blocks/master/scripts/fetch_config/fetch_config.rb -o bin/fetch_config.rb \
		&& chmod +x bin/fetch_config.rb \
		|| true

read-deployment-config:
	$(eval export POSTGRES_DATABASE_NAME=register-postgres-${paas_env})

read-tf-config:
	$(eval key_vault_name=$(shell jq -r '.key_vault_name' terraform/$(PLATFORM)/workspace-variables/$(DEPLOY_ENV).tfvars.json))
	$(eval key_vault_app_secret_name=$(shell jq -r '.key_vault_app_secret_name' terraform/$(PLATFORM)/workspace-variables/$(DEPLOY_ENV).tfvars.json))
	$(eval key_vault_infra_secret_name=$(shell jq -r '.key_vault_infra_secret_name' terraform/$(PLATFORM)/workspace-variables/$(DEPLOY_ENV).tfvars.json))
	$(eval space=$(shell jq -r '.paas_space_name' terraform/$(PLATFORM)/workspace-variables/$(DEPLOY_ENV).tfvars.json))

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
	$(eval export TF_VAR_paas_app_docker_image=ghcr.io/dfe-digital/register-trainee-teachers:$(IMAGE_TAG))
	$(if $(or $(DISABLE_PASSCODE),$(PASSCODE)), , $(error Missing environment variable "PASSCODE", retrieve from https://login.london.cloud.service.gov.uk/passcode))
	$(eval export TF_VAR_paas_sso_passcode=$(PASSCODE))

	az account set -s $(AZ_SUBSCRIPTION) && az account show \
	&& terraform -chdir=terraform/$(PLATFORM) init -reconfigure -backend-config=./workspace-variables/$(DEPLOY_ENV)_backend.tfvars $(backend_key)

console: read-tf-config
	cf target -s ${space}
	cf ssh register-${DEPLOY_ENV} -t -c "cd /app && /usr/local/bin/bundle exec rails c"

worker-console: read-tf-config
	cf target -s ${space}
	cf ssh register-worker-${DEPLOY_ENV} -t -c "cd /app && /usr/local/bin/bundle exec rails c"

ssh: read-tf-config
	cf target -s ${space}
	cf ssh register-${DEPLOY_ENV}

worker-ssh: read-tf-config
	cf target -s ${space}
	cf ssh register-worker-${DEPLOY_ENV}

enable-maintenance: read-tf-config ## make qa enable-maintenance / make production enable-maintenance CONFIRM_PRODUCTION=y
	$(if $(HOST_NAME), $(eval REAL_HOSTNAME=${HOST_NAME}), $(eval REAL_HOSTNAME=${DEPLOY_ENV}))
	cf target -s ${space}
	cd service_unavailable_page && cf push
	cf map-route register-unavailable register-trainee-teachers.education.gov.uk --hostname ${REAL_HOSTNAME}
	cf map-route register-unavailable register-trainee-teachers.service.gov.uk --hostname ${REAL_HOSTNAME}
	cf map-route register-unavailable education.gov.uk --hostname ${DTTP_HOSTNAME}
	echo Waiting 5s for route to be registered... && sleep 5
	cf unmap-route register-${DEPLOY_ENV} register-trainee-teachers.education.gov.uk --hostname ${REAL_HOSTNAME}
	cf unmap-route register-${DEPLOY_ENV} register-trainee-teachers.service.gov.uk --hostname ${REAL_HOSTNAME}
	cf unmap-route register-${DEPLOY_ENV} education.gov.uk --hostname ${DTTP_HOSTNAME}

disable-maintenance: read-tf-config ## make qa disable-maintenance / make production disable-maintenance CONFIRM_PRODUCTION=y
	$(if $(HOST_NAME), $(eval REAL_HOSTNAME=${HOST_NAME}), $(eval REAL_HOSTNAME=${DEPLOY_ENV}))
	cf target -s ${space}
	cf map-route register-${DEPLOY_ENV} register-trainee-teachers.education.gov.uk --hostname ${REAL_HOSTNAME}
	cf map-route register-${DEPLOY_ENV} register-trainee-teachers.service.gov.uk --hostname ${REAL_HOSTNAME}
	cf map-route register-${DEPLOY_ENV} education.gov.uk --hostname ${DTTP_HOSTNAME}
	echo Waiting 5s for route to be registered... && sleep 5
	cf unmap-route register-unavailable register-trainee-teachers.education.gov.uk --hostname ${REAL_HOSTNAME}
	cf unmap-route register-unavailable register-trainee-teachers.service.gov.uk --hostname ${REAL_HOSTNAME}
	cf unmap-route register-unavailable education.gov.uk --hostname ${DTTP_HOSTNAME}
	cf delete register-unavailable -r -f

get-image-tag:
	$(eval export TAG=$(shell cf target -s ${space} 1> /dev/null && cf app register-${paas_env} | awk -F : '$$1 == "docker image" {print $$3}'))
	@echo ${TAG}

get-postgres-instance-guid: ## Gets the postgres service instance's guid make qa get-postgres-instance-guid
	$(eval export DB_INSTANCE_GUID=$(shell cf target -s ${space} 1> /dev/null && cf service register-postgres-${paas_env} --guid))
	@echo ${DB_INSTANCE_GUID}

rename-postgres-service: ## make qa rename-postgres-service
	cf target -s ${space} 1> /dev/null
	cf rename-service register-postgres-${paas_env} register-postgres-${paas_env}-old

remove-postgres-tf-state: terraform-init ## make qa remove-postgres-tf-state PASSCODE=xxxx
	terraform -chdir=terraform/$(PLATFORM) state rm module.paas.cloudfoundry_service_instance.postgres_instance

set-restore-variables:
	$(if $(IMAGE_TAG), , $(error can only run with an IMAGE_TAG))
	$(if $(DB_INSTANCE_GUID), , $(error can only run with DB_INSTANCE_GUID, get it by running `make ${space} get-postgres-instance-guid`))
	$(if $(SNAPSHOT_TIME), , $(error can only run with BEFORE_TIME, eg SNAPSHOT_TIME="2021-09-14 16:00:00"))
	$(eval export TF_VAR_paas_docker_image=ghcr.io/dfe-digital/register-trainee-teachers:$(IMAGE_TAG))
	$(eval export TF_VAR_paas_restore_from_db_guid=$(DB_INSTANCE_GUID))
	$(eval export TF_VAR_paas_db_backup_before_point_in_time=$(SNAPSHOT_TIME))
	echo "Restoring register-trainee-teachers from $(TF_VAR_paas_restore_from_db_guid) before $(TF_VAR_paas_db_backup_before_point_in_time)"

restore-postgres: set-restore-variables deploy ##  make qa restore-postgres IMAGE_TAG=12345abcdef67890ghijklmnopqrstuvwxyz1234 DB_INSTANCE_GUID=abcdb262-79d1-xx1x-b1dc-0534fb9b4 SNAPSHOT_TIME="2021-11-16 15:20:00" PASSCODE=xxxxx

restore-data-from-nightly-backup: read-deployment-config read-tf-config # make production restore-data-from-nightly-backup CONFIRM_PRODUCTION=YES CONFIRM_RESTORE=YES BACKUP_DATE="yyyy-mm-dd"
	bin/download-nightly-backup REGISTER-BACKUP-STORAGE-CONNECTION-STRING ${key_vault_name} ${BACKUP_CONTAINER_NAME} register_${paas_env}_ ${BACKUP_DATE}
	$(if $(CONFIRM_RESTORE), , $(error Restore can only run with CONFIRM_RESTORE))
	bin/restore-nightly-backup ${space} ${POSTGRES_DATABASE_NAME} register_${paas_env}_ ${BACKUP_DATE}

upload-review-backup: read-deployment-config read-tf-config # make review upload-review-backup BACKUP_DATE=2022-06-10 APP_NAME=1234
	bin/upload-review-backup REGISTER-BACKUP-STORAGE-CONNECTION-STRING ${key_vault_name} ${BACKUP_CONTAINER_NAME} register_${paas_env}_${BACKUP_DATE}.tar.gz

backup-review-database: read-deployment-config # make review backup-review-database APP_NAME=1234
	bin/backup-review-database ${POSTGRES_DATABASE_NAME} ${paas_env}

deploy-domain-resources: check-auto-approve domain-azure-resources # make register deploy-domain-resources AUTO_APPROVE=1

check-auto-approve:
	$(if $(AUTO_APPROVE), , $(error can only run with AUTO_APPROVE))

register:
	$(eval include global_config/register-domain.sh)

domains-infra-init: set-production-subscription set-azure-account
	terraform -chdir=terraform/custom_domains/infrastructure init -reconfigure -upgrade \
		-backend-config=workspace_variables/${DOMAINS_ID}_backend.tfvars

domains-infra-plan: domains-infra-init # make register domains-infra-plan
	terraform -chdir=terraform/custom_domains/infrastructure plan -var-file workspace_variables/${DOMAINS_ID}.tfvars.json

domains-infra-apply: domains-infra-init # make register domains-infra-apply
	terraform -chdir=terraform/custom_domains/infrastructure apply -var-file workspace_variables/${DOMAINS_ID}.tfvars.json ${AUTO_APPROVE}

domains-init: set-production-subscription set-azure-account
	$(if $(PR_NUMBER), $(eval DEPLOY_ENV=${PR_NUMBER}))
	terraform -chdir=terraform/custom_domains/environment_domains init -upgrade -reconfigure -backend-config=workspace_variables/${DOMAINS_ID}_${DEPLOY_ENV}_backend.tfvars

domains-plan: domains-init  # make register qa domains-plan
	terraform -chdir=terraform/custom_domains/environment_domains plan -var-file workspace_variables/${DOMAINS_ID}_${DEPLOY_ENV}.tfvars.json

domains-apply: domains-init # make register qa domains-apply
	terraform -chdir=terraform/custom_domains/environment_domains apply -var-file workspace_variables/${DOMAINS_ID}_${DEPLOY_ENV}.tfvars.json ${AUTO_APPROVE}

domains-destroy: domains-init # make register qa domains-destroy
	terraform -chdir=terraform/custom_domains/environment_domains destroy -var-file workspace_variables/${DOMAINS_ID}_${DEPLOY_ENV}.tfvars.json

set-production-subscription:
	$(eval AZ_SUBSCRIPTION=s189-teacher-services-cloud-production)

domain-azure-resources: set-azure-account set-azure-template-tag set-azure-resource-group-tags #
	$(if $(AUTO_APPROVE), , $(error can only run with AUTO_APPROVE))
	az deployment sub create -l "UK South" --template-uri "https://raw.githubusercontent.com/DFE-Digital/tra-shared-services/${ARM_TEMPLATE_TAG}/azure/resourcedeploy.json" \
		--name "${DNS_ZONE}domains-$(shell date +%Y%m%d%H%M%S)" --parameters "resourceGroupName=${RESOURCE_NAME_PREFIX}-${DNS_ZONE}domains-rg" 'tags=${RG_TAGS}' \
			"tfStorageAccountName=${RESOURCE_NAME_PREFIX}${DNS_ZONE}domainstf" "tfStorageContainerName=${DNS_ZONE}domains-tf"  "keyVaultName=${RESOURCE_NAME_PREFIX}-${DNS_ZONE}domains-kv" ${WHAT_IF}

validate-domain-resources: set-what-if domain-azure-resources # make register validate-domain-resources
