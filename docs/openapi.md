# OpenAPI integration

An OpenAPI schema has been generated using the `rspec-openapi` gem.

The Schema can be kept up-to-date by running the api specs with the OPENAPI env thus:

> Run the latests version or each individually versions in order to correctly generate the api docs.

```bash
OPENAPI=1 bundle exec rspec spec/requests/api/v1_0_pre/
OPENAPI=1 bundle exec rspec spec/requests/api/v0_1/
```

This will overwrite the existing schema but _should_ preserve manually made changes.

Care must be taken when running this command to preserve all manually made changes.

In short, *check the diff*.

## Notes on specs

In order to minimise the diff.
All specs are run on the time date of
```ruby
time = Time.zone.local(current_academic_year, 9, 15, 12, 34, 56)
```

Specs that is `time sensitives` need to marked as `time_sensitive: true` to it's metadata in order for it to run using the `real` time.
Specs that is not needed should be marked as `openapi: false` to it's metadata.
Specs are run in a defined order.
