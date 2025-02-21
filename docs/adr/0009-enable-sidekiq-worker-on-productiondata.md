# 9. Enable Sidekiq worker on productiondata

Date: 2024-07-17

## Status

Accepted

## Context

In preparation for the next academic year we need to test the changes that we’ve made in the `productiondata` environment.

Generally the worker is off as there is no need for it to be running all the time.

It is also off by default to prevent any unintentional mishaps.

## Decision

We scaled the Sidekiq worker to 1 replica for `productiondata` so that the jobs will function.

## Consequences

1. Extra cost as a Sidekiq worker deployment is active
2. We have to be mindful of what actions we perform in the application and what jobs those may trigger
3. After we have completed our testing the Sidekiq worker should be scaled back to 0 replicas
