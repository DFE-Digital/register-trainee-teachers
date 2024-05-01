# OpenAPI integration

An OpenAPI schema has been generated using the `rspec-openapi` gem.

The Schema can be kept up-to-date by running the api specs with the OPENAPI env thus:

```
OPENAPI=1 brspec spec/requests/api/v0.1/
```

This will overwrite the existing schema but _should_ preserve manually made changes.

Care must be taken when running this command to preserve all manually made changes.

In short, *check the diff*.