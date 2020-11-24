# 3. Connections to DTTP Dynamics

Date: 2020-11-23

## Status

Accepted

## Context

To read and modify data in DTTP, we need to be able to connect to it's Dynamics
instance and modify data there. Dynamics has a built-in [OData API](https://www.odata.org/)
which we can use, however it exposes the data at a
low level, bypassing business logic and free of association definitions, which
sit in the web portal app. This app is an Angular app so by it's nature doesn't
have a way of presenting an API.

## Options

### 1. The Intermediary Shim

Develop a small "shim" which would sit near the Dynamics instance and would
define the entity associations and any business logic required, and
would expose an API for accessing the data. This is the approach
[taken by GiT](https://dfedigital.atlassian.net/wiki/spaces/GGIT/pages/1581973641/Events+API+and+Candidate+API).

#### Pros

1. Cleaner interface to the DTTP data, keeps the logic where it belongs, with the data.
2. Allows use of .NET libraries that may maintain better compatibility target system.
3. Reusable by other services if necessary.

#### Cons

1. Extra system to maintain with separate, more restrictive, deployment environment.
2. .NET isn't core skillset of current team.

### 2. Logic embedded in Register

In this scenario, we would keep the logic necessary to use the DTTP data
embedded in the Register app, instead of encapsulating it in a component that
lives closer to the DTTP Dynamics instance as option 1 above. This would be
abstracted out into services/components in the app, but would be deployed out
and run within the app.

The connection in this scenario is done with a service account through an app
registration on Azure Active Directory for the environment. 

#### Pros

1. Simpler integration and deployments with the app.
2. Technology within core skillset of the current team.

#### Cons

1. Less elegant solution spreads core logic across apps.
2. Risk of issues if underlying DTTP Dynamics system changes, e.g. if schema
   changes or if OData implementation changes.
3. Not reusable by other systems. 

## Decision

Option 2, embedding the logic within the Register app, has been chosen becauce
of it's easier route to development and deployment. As of yet there is no use
for giving access to the data in DTTP to any other services. It is possible that
the Register app will replace DTTP completely, obviating the need for an API
completely.

An API can always be developed at a later date if and when requirements are
better understood.

## Consequences

Development will proceed more quickly but at the risk of the system being more brittle
if DTTP changes/updates.
