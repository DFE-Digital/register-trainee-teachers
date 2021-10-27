Support Playbook
================

## Changing training route

Sometimes support will ask a dev to update the training route. Here is an example for updating a route to `school_direct_salaried`.

```
trainee = Trainee.find_by(slug: "XXX")
manager = RouteDataManager.new(trainee: trainee)
manager.update_training_route!("school_direct_salaried")
```

A bunch of fields will be set to `nil`, see `RouteDataManager` class. Ask support to communicate with the user to update the Trainee record for the missing information.

## Dttp::RetrieveTrnJob for Trainee id: <id> has timed out after 4 days.

We have a timeout set for retries on this job. It defaults to 4 days from the date it was originally enqueued. Usually there has just been a delay at DQT. Check the trainee on DTTP or with the operations team and then usually the job can be requeued.

```
Dttp::RetrieveTrnJob.perform_later(Trainee.find(<id>), 1.days.from_now)
```

The second argument is the new timeout.

## Unable to find DTTP school with URN

The `RegisterForTrn` and `UpdateTraineeToDttp` jobs will fail if we can't match the URN of a school with an 'active' school in the DTTP list.

We currently only match on active or new status codes. There are other status codes e.g. proposed_to_open that can, and do, change.

* Get the trainee ID from the [retry list](https://www.register-trainee-teachers.education.gov.uk/system-admin/sidekiq/retries)
* Get the schools from the trainee that is failing in the console

```
  trainee = Trainee.find(<id>)
  trainee.lead_school
  trainee.employing_school
```

* Check that we have `Dttp::School`(s) with the URN(s).
  If we do then it is likely the `Dttp::School#status_code` is not an active one (1 or 3000000007).

  * Check the school on [GIAS](https://get-information-schools.service.gov.uk)
  * If it is open then update the `Dttp::School` to a 1 status code. The job can now be retried and should go through.
  * Add a Trello ticket for support to update DTTP

  If we don't then:

  * Check the school on [GIAS](https://get-information-schools.service.gov.uk)
  * Get support to add the school to DTTP and provide the DTTP UUID
  * The school will sync overnight but we can run the `Dttp::SyncSchoolsJob` or manually create the `Dttp::School` if that is too long

## Dttp::Client::HttpError 400

If you have to deal with this error, where the message is something along the line of: `"message":"Cannot find record to be updated"`, then the trainee record on the DTTP side may have been deleted.

You'll need to `nil` the `dttp_id` on the trainee record and possibly the `placement_assignment_dttp_id` if that is also missing in DTTP.

Before you run the commands below, make a note of the `submitted_for_trn_at` timestamp on the trainee record. You can grab this value from the database via a prod dump. You'll also need to grab the `user.dttp_id` of the user who last submitted for trn. You can check the name on the trainee's timeline and query the `trainee.provider.users` or just check the `trainee.audits`.

```ruby
# Find the trainee
trainee = Trainee.find(5913)

# Ensure you have noted `submitted_for_trn_at`
submitted_for_trn_at = trainee.submitted_for_trn_at

# Fetch the user's dttp id based on audit state change from draft to submitted_for_trn
users_dttp_id = trainee.audits.find_by("audited_changes -> 'state' = '[0, 1]'").user.dttp_id

# Use the without_auditing method to avoid adding to the audit trail. We need to use update_columns to avoid the LockedAttributeError when setting the dttp_id
trainee.without_auditing do
  trainee.update_columns(dttp_id: nil, placement_assignment_dttp_id: nil, state: "draft", submitted_for_trn_at: nil)
end

# Fire the job to register for trn and pass in the user's dttp_id
Dttp::RegisterForTrnJob.perform_later(trainee, users_dttp_id)

# Set the state back to submitted_for_trn and the submitted_for_trn_at timestamp to the one we grabbed earlier. The timestamp needs to be exact or the audit trail will be wrong.
trainee.without_auditing do
  trainee.update_columns(state: "submitted_for_trn", submitted_for_trn_at: submitted_for_trn_at)
end

# Fire off job to retrieve trn
Dttp::RetrieveTrnJob.perform_with_default_delay(trainee)
```

It's worth double checking that those two jobs have been called successfully via the Sidekiq dashboard and also the trainee's timeline looks exactly as before the changes.