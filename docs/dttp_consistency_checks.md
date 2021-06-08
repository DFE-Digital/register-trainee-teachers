DTTP Consistency Checks
=======================

When a trainee is submitted for TRN their record is persisted to the D(atabase of) T(trainee) T(eachers and) P(roviders). This is the legacy system for storing this data but needs to be updated for now.

We don't want users to subsequently update the data in DTTP as we don't sync changes back. 

To alert us if this happens we run a consistency check.

### Consistency check flow

* After any update that Register performs on DTTP we run `CreateOrUpdateConsistencyCheck`. This queries DTTP and gets the `updated_at` date from the DTTP `Contact` entity and from the DTTP `PlacementAssignment` entity. It then stores this on a `ConsistencyCheck` object associated to the `Trainee`
* We run a nightly job `RunConsistencyChecksJob` that loops through the `ConsistencyCheck`s, queries DTTP again and compares the `updated_at` dates to those stored on the `ConsistencyCheck`
* If the dates have changed on DTTP a notification is posted to Slack (#twd_publish_register_support) with a link to the trainee on Register.

### When a check fails

* Check the audit log on the the trainee record on DTTP (Related/Audit History). This should contain information about the update that has taken place.
* Restore order by getting the records back in sync
* Run `CreateOrUpdateConsistencyCheck` for the trainee to reset the dates

Ideally this shouldn't be happening so it may be necessary to liaise with support and contact the user. If there is a system process causing the issue further investigation might be needed.


Author: Graham Pengelly
Review: 08-12-2021
