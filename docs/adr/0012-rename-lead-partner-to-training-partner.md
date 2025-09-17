# 12. Rename Lead Partner to Training Partner

Date: 2025-09-15

## Status

Proposed

## Context

The term _Lead Partner_ has been used in our system to refer to organizations that provide training services. We would like to change the term to _Training Partner_ to better reflect their role and responsibilities.

This document lists the steps required to rename _Lead Partner_ to _Training Partner_ across our system. We will divide the work into essential changes and non-essential ones.

## Essential changes

### User interface

The term _Lead Partner_ appears in many places in the user interface. Most of the visible references are in the following areas:

- Views and partials (e.g. `app/views/lead_partners/_form.html.erb`)
- Locale files (e.g. `config/locales/en.yml`)
- Components (e.g. `app/components/lead_partner_component.rb`)

The minimum required changes are to update these files to replace _Lead Partner_ with _Training Partner_. This can be done semi-automatically using search-and-replace tools, but will require careful review to ensure that variable and class names in code aren't changed (at least initially). A first pass has been implemented in 

## Non-essential changes

### Codebase

There are over 2000 instances of the term 'lead_partner' or 'lead partner' in our codebase. As well as the view, locale and component files listed above there are:

- Model names (e.g. `LeadPartner`, `LeadPartnerUser`)
- Variable names (e.g. `lead_partner`, `lead_partner_id`)
- Method names (e.g. `lead_partner?`, `set_lead_partner`)


#### Audit trail

Audit logs contain references to the `LeadPartner` model name. To preserve the audit history we would need to do some kind of data migration to fix this.

### API

API version `v2025.0` references _Lead Partner_ in two attributes of the `Trainee` resource:

- `lead_partner_urn`
- `lead_partner_ukprn`

To change these we would need to:

- update the API and CSV documentation
- change the names in the Trainee schema
- update the API code to use the new names (`TraineeAttributes` etc)

This would be a breaking change, even if we were to provide the old names as deprecated aliases. Having an alias on the input request would help for incoming trainees e.g. `POST /trainees`. Output trainees could be more problematic. To ensure backward compatibility we would have to output the value using both the old and new names or just wait until we increment the major API version.

So we expect to tackle the name change in a future API version, e.g. `v2026.0`. We would probably have to keep the old 'lead partner' name in the API for the `v2025.x`. This may be inconsistent with the Web interface and codebase, but it would avoid disruption for API consumers.

Both the API and CSV documentation would also need to be updated to reflect the new names, along with an explanation in the release notes.

### Database schema

Assuming we change the names in our codebase, it would be helpful to also change the corresponding names of the database tables, columns and indexes. For example, the `lead_partner_id` column in the `trainees` table should change to `training_partner_id`. Such changes are not strictly necessary, but they would help keep the codebase consistent and easier to understand, i.e. reduce technical debt.

The name 'lead_partner' appears in the following table names:

- `lead_partners`
- `lead_partner_users`

It also appears in the following columns:

- `trainees.lead_partner_id`
- `trainees.lead_partner_not_applicable`
- `lead_partner_users.lead_partner_id`
- `bulk_update_recommendations_upload_rows.lead_partner`
- `funding_trainee_summary_rows.lead_partner_urn`
- `funding_trainee_summary_rows.lead_partner_name`
- `hesa_students.lead_partner_urn`
- `school_data_downloads.lead_partner_updated`

(and various indexes.)

#### Analytics

Database schema changes would be a breaking change for anything that makes direct SQL queries to the Register database. In particular:

- Analytics dashboards
- Big Query
- Saved blazer queries

