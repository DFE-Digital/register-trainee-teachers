---
title: Developing on the API
weight: 4
---

# Developing on the API

## Reference spreadsheet

You can use the Register API reference spreadsheet to map trainee data from your student record system into the Register service via the Register API.

Register API reference spreadsheet contains the following information:

- field requirement
- entity
- description
- whether a field is optional or mandatory
- whether it allows multiple values
- minimum and maximum instances
- character length
- format rules
- HESA data type, alignment, code examples, labels, link to their data reference webpage and confirmation if the HESA validation is applicable

You must only use the reference spreadsheet v0.1 for use in testing and feedback of API v0.1 within the sandbox environment.

Download [Register API reference spreadsheet v0.1 (Excel)](/api-docs/reference/Register_API_Reference_v0.1.xlsx)

## OpenAPI

The OpenAPI spec for this API is <a href="/api-docs/v0.1/openapi" target="_blank">available in YAML format</a>.

## Authentication

All requests must be accompanied by an `Authorization` request header (not as part of the URL) in the following format:

`Authorization: Bearer {token}`

Unauthenticated requests will receive an `UnauthorizedResponse` with a `401` status code.

Authentication tokens will be provided by the Register team.