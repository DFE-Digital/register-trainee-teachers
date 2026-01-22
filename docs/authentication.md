# Authentication

## Basic Auth

The Register QA environment is protected by basic auth. The username and password can be provided by a Register team member.

## DfE Sign in

To access the staging, sandbox, production, and production data environments, you will need to sign in with DfE Sign-in.

## TRS

To work with TRS locally, you will need to set the following information in your `development.local.yml`:

```yml
trs:
  base_url: https://dev.teacher-qualifications-api.education.gov.uk/
  api_key: dev password
```
