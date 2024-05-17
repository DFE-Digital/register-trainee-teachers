# Smoke Tests

## Overview
Login smoke testing is defined in [spec/smoke/login_spec.rb](../spec/smoke/login_spec.rb). This document provides guidance on running the smoke tests on external environments, such as [staging](http://staging.register-trainee-teachers.service.gov.uk/) or [production](http://register-trainee-teachers.service.gov.uk/).

The test technically runs against all environments but exits immediately unless `dfe-sign-in` is enabled for that environment:

```ruby
before do
  skip "DfE sign-in not enabled" unless Settings.features.sign_in_method == "dfe-sign-in"
end
```

## Password Changes

If DfE Sign-in (DSI) has forced a password change and smoke tests are failing, follow these steps:

1. Retrieve the existing password for smoke testing from @d-a-v-e or via the environment variables in staging. Look for `SMOKE_TEST_PASSWORD`. Refer to the [Makefile](../Makefile) for guidance on printing app secrets for the staging environment.
   
2. Reset the password for *both* staging and production by logging in as usual and following the instructions for resetting or requesting a password reset.

3. Update the smoke test password for GitHub Actions in [SMOKE_TEST_PASSWORD](https://github.com/DFE-Digital/register-trainee-teachers/settings/secrets/actions/SMOKE_TEST_PASSWORD).

4. If a verification code is required for the password update, note that all emails sent to Register.SmokeTesting@education.gov.uk are forwarded to the twd-register-devs@education.gov.uk mailing list.

5. Ensure the `SMOKE_TEST_PASSWORD` is updated in the production environment for safe keeping. Consult the [Makefile](../Makefile) for guidance on this.

## Basic Auth Changes

The staging app uses basic auth, and therefore, the basic auth username and password credentials must also be stored in GitHub Actions for smoke testing to run successfully. If either the username or password changes, the GitHub Actions credentials must be updated:

1. Update the credentials for both [BASIC_AUTH_PASSWORD](https://github.com/DFE-Digital/register-trainee-teachers/settings/secrets/actions/BASIC_AUTH_PASSWORD) and [BASIC_AUTH_USERNAME](https://github.com/DFE-Digital/register-trainee-teachers/settings/secrets/actions/BASIC_AUTH_USERNAME).

2. Update these values in the staging environment using the `edit-app-secrets` action.
