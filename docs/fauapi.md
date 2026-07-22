# FauAPI integration

[Find and Use an API](https://find-and-use-an-api.education.gov.uk/) (fauapi) is DfE's central API catalogue. We publish the Register API spec there so it shows up in the directory.

## Current status

We publish to both FauAPI **pre-prod** and **production** on every deploy to production. The OpenAPI spec is attached via `schema.documentContentValue` (base64-encoded YAML).

## How it works

On every deploy to production, GitHub Actions jobs in `build-and-deploy.yml` call `update-fauapi-catalogue.yml` twice (pre-prod and production). Each run runs `bin/generate_fauapi_manifest` to build the manifest JSON from `config/settings.yml` and the openapi yaml files in `public/openapi/`, then POSTs it to the fauapi platform API and publishes it. The current API version's OpenAPI spec is embedded in the import payload as base64-encoded YAML in `schema.documentContentValue`. Import is idempotent by `name` — repeat imports update rather than duplicate.

The manifest is generated fresh in CI on every deploy — nothing to keep in sync manually. You can run the script locally to inspect the output:

```bash
ruby bin/generate_fauapi_manifest
```

## Setup that was done

Pre-prod and production each needed a one-time workspace in the fauapi management portal. Workspaces already exist — to get access, ask an existing dev on the team to add you.

The linked API is created via import with `name: "register-trainee-teachers-api"`, `displayName: "Register trainee teachers API"` (no need to create the API by hand in an empty workspace). Note: `displayName` is globally unique across all fauapi workspaces. The CI workflow keeps it updated on each deploy.

GitHub Actions [secrets](https://github.com/DFE-Digital/register-trainee-teachers/settings/secrets/actions) needed:

| Secret | Environment |
|---|---|
| `FAUAPI_PP_AUTOMATION_TOKEN` | Pre-prod bearer token from [pp-apimanagement.education.gov.uk](https://pp-apimanagement.education.gov.uk) |
| `FAUAPI_AUTOMATION_TOKEN` | Production bearer token from [apimanagement.education.gov.uk](https://apimanagement.education.gov.uk) (workspace 51) |

These are GitHub Actions secrets only — not stored in Azure Key Vault.

## Links

| Environment | Management portal | Catalogue |
|---|---|---|
| Pre-prod | [pp-apimanagement.education.gov.uk](https://pp-apimanagement.education.gov.uk) | [pp-find-and-use-an-api.education.gov.uk](https://pp-find-and-use-an-api.education.gov.uk) |
| Production | [apimanagement.education.gov.uk](https://apimanagement.education.gov.uk) | [find-and-use-an-api.education.gov.uk](https://find-and-use-an-api.education.gov.uk) |

## Known issues (as of March 2026)

The fauapi platform API has some bugs we've reported:

- Import response doesn't include the API `id` — we work around this by listing APIs after import
