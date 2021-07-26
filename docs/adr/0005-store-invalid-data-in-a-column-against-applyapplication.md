# 5. Store invalid data in a column against ApplyApplication

Date: 2021-07-23

## Status

Accepted

## Context

We are importing applications from apply into register by using the `ApplyApplication` model as an intermediate datastore. Since these applications might contain data that is not understood by register, we need a way to handle such attributes, so that they can be prompted back to the user managing the trainee in register.

We spiked a couple of approaches; option 1, [to add accessor methods to ApplyApplication](https://github.com/DFE-Digital/register-trainee-teachers/pull/1149), and option 2, [storing invalid data on the ApplyApplication model](https://github.com/DFE-Digital/register-trainee-teachers/pull/1147).


Consensus was for option 2, but there were mixed opinions about where it should live. Some felt it should be on the relevant model, eg, invalid trainee data should be on the `Trainee` model, and invalid degree data on the `Degree` model.

On the other hand, if we did move it to `Trainee`, it could get confusing, since it can be argued that `trainee.invalid_data` should account for all fields on the trainee and we already have validations to check the state of the trainee data entered in our system before submission.


## Decision

We decided to keep it on the `ApplyApplication` model, and wipe it out on successful submission of a TRN.

## Consequences

The advantage of the decision is that `ApplyApplication` becomes a single source of truth when the system wants to know about invalid data coming in from Apply. Since we are not polluting the original application dump, but rather, introducing a new column, there is minimal risk of losing the original context.

At this stage, keeping this info across multiple models/tables seems cumbersome, especially if we have to handle more unique sections in the future (more places to reset this data once an application is finished).
