# 5. Academic Cycles

Date: 2021-11-23

## Status

Accepted

## Context

We have introduced the concept of academic cycles. All trainees, courses and funding rules will need to be linked to an academic cycle.

## Decision

We need a way to “associate” all of the given above entities to reliably determine a trainee’s academic cycle and the associated funding rules applied for that cycle.

Our `funding_methods` table will have a foreign key linking to the `academic cycles` table. Since funding rules are cycle specific, it made sense to have a hard association between these two tables as their start and end dates correlate.

## Consequences

In doing the above, we’ll be able to query trainees via the `AcademicCycle` model. We can effectively ask the `AcademicCycle` for its trainees and courses using the start dates on the latter two models.

The `AcademicCycle` model will return all the trainees and courses with start dates falling within its period.

We’ll also be able to check the funding rules since we’ll have a hard association between the cycle and the funding rules.
