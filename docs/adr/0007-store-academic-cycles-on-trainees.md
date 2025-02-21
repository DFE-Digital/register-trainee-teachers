# 7. Store academic cycles on trainees

Date: 2022-06-28

## Status

Accepted

## Context

We need to be able to identify the academic cycle that a trainee started in and
the academic cycle that they finish in.

## Decision

### Storing the associations

We decided to associate `trainees` with `academic_cycles`, storing two foreign
keys on the trainee table:

* `start_academic_cycle_id` to record the academic cycle the trainee ‘started’
  training in, and
* `end_academic_cycle_id` to record the academic cycle the trainee ‘finished’
  in.

### Setting the associations

At various times during the trainee’s lifecycle the data can change requiring us
to update the academic cycles, for example, we have a trainee with a course end date in
August that ends up getting awarded in October.

We decided to create a service `Trainees::SetAcademicCycles` which is
responsible for calculating the academic cycles based on the rules set out
below (See **Calculating the cycles**) and setting them on a trainee.

This service is called from a job `Trainees::SetAcademicCyclesJob` which is in
turn kicked off from within our `Trainees::Update` service.

This `Trainees::Update` service is invoked explicitly by us whenever a trainee
is updated via the UI (i.e. in all form objects). Setting the academic cycles
here means that we catch all occurrences of actions that might affect the cycles
without the risk of mass-updates caused by a callback.

We can also use this new service to backfill the associations on all existing
trainees.

### Calculating the cycles

Rules for determining start academic cycle:

1. Use the trainee’s start date.
2. If trainee start date is missing, use their ITT start date.
3. If the ITT start date is missing, default to the current cycle.

Rules for determining end academic cycle:

1. Use the trainee’s award date or withdrawal date.
2. If neither of those dates are present, use their ITT end date.
3. If ITT end date is missing, use their course duration (from HESA) in
  combination with their ITT start date.
4. If course duration is missing, use a duration of:

* three years for trainees on undergrad courses
* two years for part-time trainees
* one if neither of those apply

## Consequences

This association between trainees and academic years makes it easier and quicker
for us to query for all trainees starting in a particular academic year, which
is especially useful for our ‘start year’ and ‘end year’ filters.
