# 13. Rename 'awarded' to 'holds'

Date: 2025-09-17

## Status

Pending

## Context

Register uses the term 'awarded' to describe the end state for trainees that have attained their teaching qualification. This term permeates many parts of the system. For example, trainee records have `recommended_for_award_at` and `awarded_at` attributes to record the milestones for the trainee gaining their award.

Other services within DfE use the term 'holds' to describe a person having a teaching qualification. For example, the TRS API for updating a trainee's professional status includes a `holdsFrom` attribute for the date on which the trainee became a qualified teacher.

## Changes needed

## Agree on the precise terminology for 'award' related concepts

The switch from the term 'award' to 'holds' isn't a simple find-and-replace because that wouldn't work grammatically in all cases. e.g. `recommended_for_award` -> `recommended_for_hold` doesn't make sense.

These are the variations on 'award' that we need to consider:

- awarded (the trainee status etc.)
- awarded at (trainee attribute)
- recommended for award (trainee status)
- recommended for award at (trainee status)
- not awarded
- award type
- EYTS awarded / QTS awarded (for filtering trainees - not sure this is used)
- award standards met
- awarding institution (this relates to degrees rather than teacher training so is out of scope)
- pending awards
- award date
- waiting for award
- awarded this year

The term 'holds' (or 'held') can replace the word 'awarded' but doesn't make much sense in other contexts where a noun is needed e.g. 'award'. So we need to come up with a clear terminology.

## Essential changes

Once we have worked out what the correct terminology is we can start working on the implementation.

### Front-end changes

Updates to:

- view templates
- component templates
- localisable strings

For these we need a consistent approach to how we handle the different variations of the terminology as outlined above.

#### Status labels

For the `recommended_for_award` state we display a label that depends on the type of qualification:

- _Recommended for EYTS_
- _Recommended for QTS_

These already hide the word 'award' so they don't need to change.

The awarded state label also depends on the type of qualification:

- _EYTS awarded_
- _QTS awarded_

These would need to change to:

- _Holds EYTS_
- _Holds QTS_

For filters on the trainees index page we currently have states grouped under 5 options:

- _Course not started yet_
- _In training_
- _Deferred_
- _Awarded_
- _Withdrawn_

Only the 'Awarded' option would need to change to 'Holds' or similar (though by itself the word is rather ambiguous).

## Non-essential changes

### Back-end code

There are a lot of references to 'award' in the back-end code, including class names, method names, variable names, comments and tests. We would need to decide how far we want to go with renaming these.

#### Trainee states

There are two trainee states that contain the word `award`. From a consistency point of view renaming these is important, however it's quite a far reaching change. Apart from the various method names that are derived from the states, this would also impact the API and CSV upload features, and anything else that uses the state names such as ad-hoc SQL queries and analytics dashboards. This would be a breaking change for API consumers.

### API and CSV upload

The term 'award' only appears in state values (reference data). This would be a breaking change so it would have to be handled carefully and probably deferred until the next major version in September 2026.

#### Bulk recommend

The bulk recommend feature doesn't use the term 'award' in the CSV template, so no changes are needed except to review the content on the upload page ('award' is mentioned once).

### Database schema

There are only two columns in the schema that contain the word _award_ (and no tables).

- `trainees.recommended_for_award_at`
- `trainees.awarded_at`



