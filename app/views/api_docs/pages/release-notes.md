---
page_title: Register API release notes
title: Register API release notes
---

## v2025.0-rc - 29 April 2025

Release canidate of first major version of the Register API. This version is not
yet live but is available for testing. All requests for `v1.0-pre` will redirect to
this version.

## v1.0-pre — 12 August 2024

Pre-release of the first major version of the Register API. This version is not
yet live but is available for testing.

### Changes

* `application_id` is now supported
* New `POST /trainees/{trainee_id}/withdraw` endpoint to withdraw a trainee
* New `POST /trainees/{trainee_id}/defer` endpoint to defer a trainee
* New `POST /trainees/{trainee_id}/recommend-for-qts` endpoint to recommend a trainee for QTS
* Changes for ITT Reform 2024. These include support for lead partners and changes to the validation rules
* Better duplicate checks for degrees and placements
* Improved error messages for validation errors

## v0.1 — 22 April 2024

The draft version of the Register API was released on 22 April 2024. This is the first version of the API and will be subject to changes which may not be backward compatible.

### Known issues

* The `application_id` field is not currently supported but will be added in a future release.
