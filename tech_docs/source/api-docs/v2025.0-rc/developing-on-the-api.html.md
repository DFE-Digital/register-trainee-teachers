---
title: Developing on the API
weight: 3
---

# Developing on the API

## OpenAPI

The OpenAPI spec for this API is <a href="/api-docs/v2025.0-rc/openapi" target="_blank">available in YAML format</a>.

## Authentication

All requests must be accompanied by an `Authorization` request header (not as part of the URL) in the following format:

`Authorization: Bearer {token}`

Unauthenticated requests will receive an `UnauthorizedResponse` with a `401` status code.

Authentication tokens will be provided by the Register team.

## Rate Limiting

API requests are rate limited to prevent abuse and ensure fair usage across all users.

**Current rate limit:** 100 requests per 60 seconds per IP address
