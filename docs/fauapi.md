# FauAPI integration

[Find and Use an API](https://find-and-use-an-api.education.gov.uk/) (fauapi) is DfE's central API catalogue. We publish the Register API spec there so it shows up in the directory.

## How it works

On every deploy to production, a GitHub Actions job (`update-fauapi-catalogue` in `build-and-deploy.yml`) runs `bin/generate_fauapi_manifest` to build the manifest JSON from `config/settings.yml` and the openapi yaml files in `public/openapi/`, then POSTs it to the fauapi platform API and publishes it. Import is idempotent by `name` — repeat imports update rather than duplicate.

The manifest is generated fresh in CI on every deploy — nothing to keep in sync manually. You can run the script locally to inspect the output:

```bash
ruby bin/generate_fauapi_manifest
```

## Setup that was done

Both pre-prod and production required manual one-time setup in the fauapi management portal. Workspaces already exist — to get access, ask an existing dev on the team to add you.

The linked API was created via import with `name: "register-trainee-teachers-api"`, `displayName: "Register Trainee Teachers API"`. The CI workflow keeps it updated on each deploy.

A `FAUAPI_AUTOMATION_TOKEN` [secret](https://github.com/DFE-Digital/register-trainee-teachers/settings/secrets/actions) is needed in GitHub Actions — this is a bearer token from the fauapi management portal.

## Links

| | Management portal | Catalogue |
|---|---|---|
| Pre-prod | [pp-apimanagement.education.gov.uk](https://pp-apimanagement.education.gov.uk) | [pp-find-and-use-an-api.education.gov.uk](https://pp-find-and-use-an-api.education.gov.uk) |
| Production | [apimanagement.education.gov.uk](https://apimanagement.education.gov.uk) | [find-and-use-an-api.education.gov.uk](https://find-and-use-an-api.education.gov.uk) |

## Known issues (as of Mar 2025)

The fauapi platform API has some bugs we've reported:

- `schemaUrl` and `schemaType` in the import payload are silently ignored — the OpenAPI spec doesn't get attached
- `baseUrl` on environment objects is silently dropped
- Publish endpoint returns `{ "status": 400 }` in the body with HTTP 200 — acknowledged as their bug
- Import response doesn't include the API `id` — we work around this by listing APIs after import
