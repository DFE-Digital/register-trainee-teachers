# 13. Rename 'awarded' to 'holds'

Date: 2025-09-17

## Status

Pending

Accepted

## Context

Register uses the term 'awarded' to describe the end state for trainees that have attained there teaching qualification. This term permeates many parts of the system. For example, trainee records have `recommended_for_award_at` and `awarded_at` attributes to record the milestones for the trainee gaining their award.

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

Once we have worked out what the correct terminiology is we can start working on the implementation.

### Front-end changes


