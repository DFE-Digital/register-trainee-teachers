* 10. Use token authentication for API access

Date: 2025-02-19

## Status

Accepted

## Context

For Register API access, bearer tokens will be used by external clients. The clients can self-service with tokens through admin screens in the Register App.

Although the preferred method of external client API Access is OAuth, this requires a solution for ITT Providers that provides a self-service customer managment portal that is also consistent with the offering from Apply as the same ITT Providers use both systems and consistency needs to be a key consideration.

The OAuth solution is still in the discussion / design phase, so will not be ready for go live for the Register API with enough lead time for ITT Providers client development, hence the decision to go live with bearer tokens.

## Decision

Use bearer tokens for API Authentication for external clients. Admin screens to manage the tokens will be developed in the Register App.

## Consequences

External clients will be able to use bearer tokens and self-serve to manage tokens. In the future, they will need to migrate to an OAuth solution when it is available.
