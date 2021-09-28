Support Playbook
================

## Dttp::RetrieveTrnJob for Trainee id: <id> has timed out after 4 days.

We have a timeout set for retries on this job. It defaults to 4 days from the date it was originally enqueued. Usually there has just been a delay at DQT. Check the trainee on DTTP or with the operations team and then usually the job can be requeued.

```
Dttp::RetrieveTrnJob.perform_later(Trainee.find(<id>), 1.days.from_now)
```

The second argument is the new timeout. 
