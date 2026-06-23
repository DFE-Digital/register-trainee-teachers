# FauAPI integration

[Find and Use an API](https://find-and-use-an-api.education.gov.uk/) (fauapi) is DfE's central API catalogue. We publish the Register API spec there so it shows up in the directory.

## Current status: pre-prod only

We're currently only publishing to FauAPI **pre-prod**. The OpenAPI spec is attached via `schema.documentContentValue` (base64-encoded YAML). Once we've verified this works in pre-prod, we'll switch the workflow to target production.

## How it works

On every deploy to production, a GitHub Actions job (`update-fauapi-catalogue` in `build-and-deploy.yml`) runs `bin/generate_fauapi_manifest` to build the manifest JSON from `config/settings.yml` and the openapi yaml files in `public/openapi/`, then POSTs it to the fauapi platform API and publishes it. The current API version's OpenAPI spec is embedded in the import payload as base64-encoded YAML in `schema.documentContentValue`. Import is idempotent by `name` — repeat imports update rather than duplicate.

The manifest is generated fresh in CI on every deploy — nothing to keep in sync manually. You can run the script locally to inspect the output:

```bash
ruby bin/generate_fauapi_manifest
```

## Setup that was done

Pre-prod required manual one-time setup in the fauapi management portal. The workspace already exists — to get access, ask an existing dev on the team to add you.

The linked API was created via import with `name: "register-trainee-teachers-api"`, `displayName: "Register trainee teachers API"`. Note: `displayName` is globally unique across all fauapi workspaces. The CI workflow keeps it updated on each deploy.

A `FAUAPI_PP_AUTOMATION_TOKEN` [secret](https://github.com/DFE-Digital/register-trainee-teachers/settings/secrets/actions) is needed in GitHub Actions — this is a bearer token from the fauapi pre-prod management portal.

Production workspace setup hasn't been done yet. Once base64 schema upload is verified in pre-prod, create the workspace + API at [apimanagement.education.gov.uk](https://apimanagement.education.gov.uk), generate a `FAUAPI_AUTOMATION_TOKEN` secret, and update the workflow to target the production URL.

## Links

| Environment | Management portal | Catalogue |
|---|---|---|
| Pre-prod | [pp-apimanagement.education.gov.uk](https://pp-apimanagement.education.gov.uk) | [pp-find-and-use-an-api.education.gov.uk](https://pp-find-and-use-an-api.education.gov.uk) |
| Production | [apimanagement.education.gov.uk](https://apimanagement.education.gov.uk) | [find-and-use-an-api.education.gov.uk](https://find-and-use-an-api.education.gov.uk) |

## Known issues (as of March 2026)

The fauapi platform API has some bugs we've reported:

- Import response doesn't include the API `id` — we work around this by listing APIs after import
