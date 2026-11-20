# 14. Match DSI users by DfE Sign-in ID

Date: 2026-11-11

## Status

Proposed — check with DSI for conformance

## Context

Register already stores the DSI `sub` as `users.dfe_sign_in_uid` on first sign in. Lookups preferred that ID and fell back to email, but a matching email still signed the user in even when the stored ID was different, and sign in could overwrite a stored ID.

Emails change in DSI. Identifying people by email alone risks linking the wrong DSI account to a Register user, or taking over an account when an email is reused.

## Options

### 1. Keep email as a soft fallback that can overwrite the stored ID

#### Pros

- No behaviour change for people who share or recycle mailboxes

#### Cons

- A DSI account can attach itself to an existing Register user that already belongs to a different DSI identity
- Stored IDs are not stable

### 2. Match by DfE Sign-in ID first; email only for first link; refuse ID mismatches

#### Pros

- Stable identity once linked
- Email updates from DSI still flow through when the ID matches
- Clear refusal when an email points at a user already linked to another DSI account

#### Cons

- Someone whose DSI account was recreated (new `sub`, same email) cannot sign in until support clears or relinks `dfe_sign_in_uid`

## Decision

Use option 2.

1. Look up by `dfe_sign_in_uid`. On match, sign in. If the DSI email differs from the stored one, update it and log with the Register user id only.
2. Else look up by email (case-insensitive).
   - No stored ID → first sign in: store the ID and sign in.
   - Different stored ID → refuse. Log reason and Register user id only (no email or DSI ID).
   - No user → `/sign-in/user-not-found`, as today.
3. Never overwrite a stored `dfe_sign_in_uid`.
4. Still refresh email, first name, last name and `last_signed_in_at` from DSI on each successful sign in.

## Consequences

- Account linking is permanent until support intervenes.
- Refused sign ins need a support path to clear or correct `dfe_sign_in_uid`.
- Logs stay free of email and DSI IDs for these events.
- Confirm the approach with DSI before treating this ADR as accepted.
