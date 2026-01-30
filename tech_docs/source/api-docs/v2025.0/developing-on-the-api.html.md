---
title: Developing on the API
weight: 3
---

# Developing on the API

## OpenAPI

The OpenAPI spec for this API is <a href="/api-docs/v2025.0/openapi" target="_blank">available in YAML format</a>.

## Authentication

All requests must be accompanied by an `Authorization` request header (not as part of the URL) in the following format:

`Authorization: Bearer {token}`

Unauthenticated requests will receive an `UnauthorizedResponse` with a `401` status code.

Providers can create tokens in the Organisation settings link once logged into the service.

## Rate Limiting

API requests are rate limited to prevent abuse and ensure fair usage across all users.

**Current rate limit:** 100 requests per 60 seconds per IP address

## Enhanced Errors

By default, validation errors are returned as an array of strings with the attribute name embedded in each message. You can opt into enhanced error responses which group errors by attribute name, making it easier to programmatically map errors to fields.

### Scope

Enhanced errors are available on the `/trainees` endpoint for:

- `POST /trainees` (create)
- `PUT /trainees/{trainee_id}` (update)
- `PATCH /trainees/{trainee_id}` (update)

### Usage

Add the `Enhanced-Errors` header to your request:

```
Enhanced-Errors: true
```

### Response Format

**Standard errors (default)**

Errors are returned as an array of strings:

<pre class="json-code-sample">
{
  "message": "Validation failed: 2 errors prohibited this trainee from being saved",
  "errors": [
    "first_names is too long (maximum is 60 characters)",
    "email Enter an email address in the correct format, like name@example.com"
  ]
}</pre>

**Enhanced errors**

With `Enhanced-Errors: true`, errors are grouped by attribute:

<pre class="json-code-sample">
{
  "message": "Validation failed: 2 errors prohibited this trainee from being saved",
  "errors": {
    "first_names": ["is too long (maximum is 60 characters)"],
    "email": ["Enter an email address in the correct format, like name@example.com"]
  }
}</pre>
