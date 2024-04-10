## Infrastructure Configuration
- Add {env}.sh file to the global_config folder. For example, pen.sh.
- Add {env}.tfvars.json, {env}_Terrafile, and {env}_backend.tfvars to terraform/aks/workspace-variables.
- Update the app_config.yml in terraform/aks/workspace-variables.
- Verify the Makefile has targets deploy-arm-resources and validate-arm-resources. If not present, add them.
-  Add register_{env}.tfvars.json and register_{env}_backend.tfvars to terraform/custom_domains/environment_domains/workspace_variables/

## Application Configuration
- Add {env}.rb to the global_config folder.

## Azure Vault Secret Entries
- Create following secrets in s189t01-rtt-<env>-kv
- BAT-INFRA-SECRETS-<ENV> and REGISTER-APP-SECRETS-<ENV>

## Deploy changes
- To deploy application changes:
    - Use the command: make pen apply IMAGE_TAG=1705-register-pen-test-environment.

- To deploy new domain changes :
    - Validate domain resources with: make register <env> validate-domain-resources.
    - Deploy Azure domain resources with: make register <env>  domain-azure-resources.
    - Plan domain deployment with: make register <env>  domains-plan.
    - Apply domain deployment with: make register <env>  domains-apply.
