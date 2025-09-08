# Register trainee teachers

A service for training providers in England to register trainees with the Department for Education and record the outcome of their training.

## Status

![Build](https://github.com/DFE-Digital/register-trainee-teachers/workflows/Build/badge.svg)
[![View performance data on Skylight](https://badges.skylight.io/status/YttDFt8jHcNT.svg)](https://oss.skylight.io/app/applications/YttDFt8jHcNT)

## Table of Contents

- [Environments](#environments)
- [Guides](#guides)
- [License](#license)

## Environments

| Name        | URL                                                                    | Description
| ----------- | ---------------------------------------------------------------------- | ------------------------------------------------------------------------------
| Production  | [www](https://www.register-trainee-teachers.service.gov.uk/)   | Public site
| Production Data  | [www](https://register-productiondata.teacherservices.cloud/)   | For internal use by DFE to validate Register data workflows
| Sandbox  | [sandbox](https://sandbox.register-trainee-teachers.service.gov.uk/)   | A sandbox environment for testing the Register API
| Staging     | [staging](https://staging.register-trainee-teachers.service.gov.uk/)| For internal use by DfE to test deploys and integrations
| QA          | [qa](https://qa.register-trainee-teachers.service.gov.uk/)     | For internal use by DfE for testing. Automatically deployed from main

## Guides

- [Configuration](/docs/configuration.md)
- [Machine Setup](/docs/machine-setup.md)
- [Setting up the application in development](/docs/setup-development.md)
- [Testing & Linting](/docs/testing.md)
- [Load Testing](/docs/load_testing/index.md)
- [Authentication](/docs/authentication.md)
- [Alerting & Monitoring](/docs/alerting_and_monitoring.md)
- [Transactional Emails](/docs/emails.md)
- [Healthchecks](/docs/healthcheck_and_ping_endpoints.md)
- [Disaster Recovery Plan](/docs/disaster-recovery.md)
- [ADRs](/docs/adr/index.md)
- [Support Playbook](/docs/support_playbook.md)
- [AKS Module Information](/docs/aks_modules.md)
- [AKS Workflows](/docs/aks-cheatsheet.md)


## License

[MIT Licence](LICENCE)
