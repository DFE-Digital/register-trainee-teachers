---
title: Release notes
weight: 2
---

# Release notes

## v2026.0 — 30 January 2026

First release of the 2026 version of the CSV bulk add new trainee feature.

This is available for testing in the [sandbox environment](https://sandbox.register-trainee-teachers.service.gov.uk/).

### Changes

* Terminology change from 'Lead Partner' to 'Training Partner'. Changes have been made to field names in the CSV template, error messages, and documentation.
* Field name changes. All of the field names have been updated as follows:

  | Previous field name | New field name |
  | --- | --- |
  | `Provider Trainee ID` | `provider_trainee_id` |
  | `Application ID` | `application_id` |
  | `HESA ID` | `hesa_id` |
  | `First Names` | `first_names` |
  | `Last Name` | `last_name` |
  | `Previous Last Name` | `previous_last_name` |
  | `Date of Birth` | `date_of_birth` |
  | `NI Number` | `ni_number` |
  | `Sex` | `sex` |
  | `Email` | `email` |
  | `Nationality` | `nationality` |
  | `Ethnicity` | `ethnicity` |
  | `Disability 1` | `disability1` |
  | `Disability 2` | `disability2` |
  | `Disability 3` | `disability3` |
  | `Disability 4` | `disability4` |
  | `Disability 5` | `disability5` |
  | `Disability 6` | `disability6` |
  | `Disability 7` | `disability7` |
  | `Disability 8` | `disability8` |
  | `Disability 9` | `disability9` |
  | `ITT Aim` | `itt_aim` |
  | `Training Route` | `training_route` |
  | `Qualification Aim` | `itt_qualification_aim` |
  | `Course Subject One` | `course_subject_1` |
  | `Course Subject Two` | `course_subject_2` |
  | `Course Subject Three` | `course_subject_3` |
  | `Study Mode` | `study_mode` |
  | `ITT Start Date` | `itt_start_date` |
  | `ITT End Date` | `itt_end_date` |
  | `Course Age Range` | `course_age_range` |
  | `Course Year` | `course_year` |
  | `Lead Partner URN` | `training_partner_urn` |
  | `Employing School URN` | `employing_school_urn` |
  | `Trainee Start Date` | `trainee_start_date` |
  | `PG Apprenticeship Start Date` | `pg_apprenticeship_start_date` |
  | `Placement 1 URN` | `placement_1_urn` |
  | `Placement 2 URN` | `placement_2_urn` |
  | `Placement 3 URN` | `placement_3_urn` |
  | `Fund Code` | `fund_code` |
  | `Funding Method` | `funding_method` |
  | `Training Initiative` | `training_initiative` |
  | `Additional Training Initiative` | `additional_training_initiative` |
  | `UK Degree type` | `uk_degree` |
  | `Non-UK Degree type` | `non_uk_degree` |
  | `Degree Subject` | `degree_subject` |
  | `Degree grade` | `degree_grade` |
  | `Degree graduation year` | `degree_graduation_year` |
  | `Awarding Institution` | `awarding_institution` |
  | `Degree country` | `degree_country` |

* Handling of course subject for primary courses:
  * An error will be returned if the age range is primary (max age 11 or less) but the `course_subject_1` is not `100511` (Primary Teaching)
* Funding rules have been updated to include the 2026 to 2027 academic year funding.

## v2025.0 — 1 September 2025

This is the 2025.0 version of the CSV bulk add new trainee guidance.

This is the current version in use in [production](https://www.register-trainee-teachers.service.gov.uk/).
