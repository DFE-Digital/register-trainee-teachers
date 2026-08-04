# FauAPI integration

[Find and Use an API](https://beta-find-and-use-an-api.education.gov.uk/) (fauapi) is DfE's central API catalogue. We publish the Register API spec there so it shows up in the directory. Publishing to it is a requirement for DfE services.

## One catalogue entry per academic year

fauapi treats the major version as part of an API's identity — the public slug is `<name>-<majorVersion>`:

- [register-trainee-teachers-api-v2025](https://beta-find-and-use-an-api.education.gov.uk/api/register-trainee-teachers-api-v2025)
- `register-trainee-teachers-api-v2026` (once published)

Because our major version is the academic year, each year gets its own catalogue entry. Importing with a new `majorVersion` creates a new entry rather than updating the existing one. Older years stay discoverable.

Within an entry, `releases` covers only that entry's own academic year. Release tags come from `api.current_version` in Settings (`Live` / `Planned` / `Deprecated`).

## How it works

`Fauapi::PublishCatalogueJob` runs weekly via Sidekiq cron (`publish_fauapi_catalogue` in `config/sidekiq_cron_schedule.yml`). It no-ops unless `Settings.fauapi.enabled` is true.

| Register env | FauAPI management API |
|---|---|
| `production` | `https://apimanagement.education.gov.uk` |
| `productiondata` | `https://pp-apimanagement.education.gov.uk` |

`Fauapi::PublishCatalogue`:

1. builds one manifest per major from `public/openapi/*.yaml` (`Fauapi::BuildManifests`)
2. POSTs each to import (`schema.documentContentValue` = base64 OpenAPI YAML) via `Fauapi::Client`
3. lists APIs, matches on `name` + `majorVersion`, publishes

Import is idempotent per entry.

### Manual run

From a production / productiondata console or Sidekiq UI:

```ruby
Fauapi::PublishCatalogueJob.perform_later
# or synchronously:
Fauapi::PublishCatalogueJob.perform_now
```

## Secrets

Automation token is `Settings.fauapi.api_key`, supplied as `SETTINGS__FAUAPI__API_KEY` from Azure Key Vault / AKS for production and productiondata (same pattern as `Settings.trs.api_key`).

Base URL and `enabled` are set in `config/settings/production.yml` and `config/settings/productiondata.yml`.

## Links

| Environment | Management portal | Catalogue |
|---|---|---|
| Pre-prod | [pp-apimanagement.education.gov.uk](https://pp-apimanagement.education.gov.uk) | [pp-find-and-use-an-api.education.gov.uk](https://pp-find-and-use-an-api.education.gov.uk) |
| Production | [apimanagement.education.gov.uk](https://apimanagement.education.gov.uk) | [beta-find-and-use-an-api.education.gov.uk](https://beta-find-and-use-an-api.education.gov.uk) |

## Known issues

- Import response doesn't include the entry `id` — we list APIs after import and match on name + majorVersion
