---
page_title: Register API release notes
title: Register API release notes
---

## v0.1 — 15 April 2024

The draft version of the Register API was released on 15 April 2024. This is the first version of the API and will be subject to change.

### Known issues

* **Some Trainee fields aren't required** - When POSTing a Trainee, some fields are not required when they should be.
* **Inconsistent responses for deleting degrees and placements** - When deleting a Placement the API responds with a Trainee object, when deleting a Degree the API responds with the Degree object.
* **Placement `name` is required on PUT/PATCH even if name doesn't need updating**


