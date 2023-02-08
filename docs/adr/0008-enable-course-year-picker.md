# 8. Enable course year picker

Date: 2022-07-11

## Status

Accepted

## Context

For the 3 months prior to an academic cycle, when picking a course we should start on the course year picker
page, rather than defaulting to the current year. This is because it's ambiguous which year they're likely to want.

## Decision

To enable this behaviour at the appropriate time, we've gone with a feature flag (`show_draft_trainee_course_year_choice`).

## Consequences

When the feature is enabled, the course year page will be displayed when the user selects a published trainee
course for the first time. It's important to disable the feature once the new academic cycle begins.
