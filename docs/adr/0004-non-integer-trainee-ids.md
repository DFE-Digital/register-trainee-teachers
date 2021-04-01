# 4. Non-integer trainee IDs

Date: 2021-04-01

## Status

Accepted

## Context

We have been using trainee IDs in the URL as per standard Rails convention/operation.

It was felt that we should use non-integer IDs for a number of reasons:

* remove predictability
* interoperability with other systems without depending on DB IDs

## Options

### 1. UUIDs

Use a 32 character UUID

#### Pros

- guaranteed to be unique
- supported in the DB as a distinct type

#### Cons

- ugly URLs
- long URLs
- impossible to type
- requires quite a lot of code changes

### 2. Continue using integer IDs


#### Pros

- no work
- works with Rails as designed

#### Cons

- predictable
- perceived as not looking 'professional'
- dependent on DB

### 3. Use Rails built in  `has_secure_token`

#### Pros

- in built uniqueness checks
- framework support
- not predictable
- not as long as a full UUID

#### Cons

- record now has two 'IDs'

## Decision

We chose to use option 3 as it met the needs we had with the minimum of effort and avoided the really long URLs that 
option 1 would have caused.

## Consequences

Trainee URLs are no longer predictable and we have an effective unique identifier.
