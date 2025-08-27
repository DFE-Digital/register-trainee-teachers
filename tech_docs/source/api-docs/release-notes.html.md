---
title: Release notes
weight: 2
---

# Release notes

## v2025.0 — 1 September 2025

First release of the 2025.0 version of the Register API.

## v2025.0-rc — 13 May 2025

Release candidate of the 2025.0 version of the Register API. This version is not
yet live but is available for testing.

### Changes

* Checks for uniqueness of disabilities
* Adds support for deferral reason to `POST /trainees/{trainee_id}/defer` endpoint
* Updated `POST /trainees/{trainee_id}/withdraw` endpoint with new data requirements to support the new withdrawal journey
* Added degree validation for `POST /trainees/{trainee_id}/recommend-for-qts` endpoint
* Added support for Lead Partner UKPRN
* Fixed placement creation when creating trainees
* Added additional validations
* Improved the responses when duplicate degree and placements are detected
* Removed some internal fields from responses
* Added support for some missing HESA data values
* Improved error messages to include exact field names in error response
* Updated reference documentation

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
