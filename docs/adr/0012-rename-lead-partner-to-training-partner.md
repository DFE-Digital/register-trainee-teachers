# 12. Rename Lead Partner to Training Partner

Date: 2025-09-15

## Status

Proposed

## Context

The term _Lead Partner_ has been used in our system to refer to organizations that provide training services. We would like to change the term to _Training Partner_ to better reflect their role and responsibilities.

This document lists the steps required to rename _Lead Partner_ to _Training Partner_ across our system. We will divide the work into essential changes and non-essential ones.

## Essential changes

## Non-essential changes

### API

API version `v2025.0` references _Lead Partner_ in two attributes of the `Trainee` resource:

- `lead_partner_urn`
- `lead_partner_ukprn`

To change these we would need to:

- update the API and CSV documentation
- change the names in the Trainee schema
- update the API code to use the new names (`TraineeAttributes` etc)

This would be a breaking change, even if we were to provide the old names as deprecated aliases. (Having an alias on the input request would help for e.g. `POST /trainees` but for the output we would have to pick one name to return and that would have to be the original until we increment the major API version.)

### Database schema

Assuming we change the names in our codebase, it would be helpful to also change the corresponding names of the database tables, columns and indexes. For example, the `lead_partner_id` column in the `trainees` table should change to `training_partner_id`. Such changes are not strictly necessary, but they would help keep the codebase consistent and easier to understand, i.e. reduce technical debt.

The name 'lead_partner' appears in the following table names:

- `lead_partners` (table)
- `lead_partner_users` (table)

It also appears in the following columns:

- `trainees.lead_partner_id` (column)
- `trainees.lead_partner_not_applicable` (column)
- lead_partner_users.lead_partner_id (column)
- `bulk_update_recommendations_upload_rows.lead_partner` (column)
- `funding_trainee_summary_rows.lead_partner_urn` (column)
- `funding_trainee_summary_rows.lead_partner_name` (column)
- `hesa_students.lead_partner_urn` (column)
- `school_data_downloads.lead_partner_updated` (column)

#  lead_partner_not_applicable     :boolean          default(FALSE)

