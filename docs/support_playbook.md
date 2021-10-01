Support Playbook
================

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

