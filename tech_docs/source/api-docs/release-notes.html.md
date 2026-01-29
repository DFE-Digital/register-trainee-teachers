---
title: Release notes
weight: 2
---

# Release notes

## v2026.0 — 30 January 2026

First release of the 2026 version of the Register API.

This is available for testing in the [sandbox environment](https://sandbox.register-trainee-teachers.service.gov.uk/).

### Changes

* Terminology change from 'Lead Partner' to 'Training Partner'. Changes have been made to field names, error messages, and documentation throughout the API.
* Field name changes:

  | Previous field name | New field name |
  |---|---|
  | `lead_partner_urn` | `training_partner_urn` |
  | `lead_partner_ukprn` | `training_partner_ukprn` |
  | `course_subject_one` | `course_subject_1` |
  | `course_subject_two` | `course_subject_2` |
  | `course_subject_three` | `course_subject_3` |
  | `withdraw_date` | `withdrawal_date` |
  | `withdraw_reasons` | `withdrawal_reasons` |

* Handling of course subject for primary courses:
  * An error will be returned if the age range is primary (max age 11 or less) but the `course_subject_1` is not `100511` (Primary Teaching)
* Funding rules have been updated to include the 2026 to 2027 academic year funding.

## v2025.0 — 1 September 2025

First release of the 2025.0 version of the Register API.

Originally released for testing as v2025.0-rc on 13 May 2025.

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
* New withdrawal `reasons` value `safeguarding_concerns` and optional field `safeguarding_concern_reasons` for `POST /trainees/{trainee_id}/withdraw`

## v1.0-pre — 12 August 2024

Pre-release of the first major version of the Register API. This version is not
yet live but is available for testing.

### Changes

* `application_id` is now supported
* New `POST /trainees/{trainee_id}/withdraw` endpoint to withdraw a trainee
* New `POST /trainees/{trainee_id}/defer` endpoint to defer a trainee
* New `POST /trainees/{trainee_id}/recommend-for-qts` endpoint to changed status of a trainee for QTS
* Changes for ITT Reform 2024. These include support for lead partners and changes to the validation rules
* Better duplicate checks for degrees and placements
* Improved error messages for validation errors

## v0.1 — 22 April 2024

The draft version of the Register API was released on 22 April 2024. This is the first version of the API and will be subject to changes which may not be backward compatible.

### Known issues

* The `application_id` field is not currently supported but will be added in a future release.
