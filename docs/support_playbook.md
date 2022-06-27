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

## Unwithdrawing a withdrawn trainee

Sometimes support will ask a dev to unwithdraw a trainee which has been withdrawn in error. You can find the previous trainee state by running `trainee.audits` and comparing the numbers to the enum in `trainee.rb`.

Here is an examole of unwithdrawing a trainee without leaving an audit trail.

```ruby
trainee = Trainee.find_by(slug: "XXX")

trainee.without_auditing do
  trainee.update_columns(state: "XXX", withdraw_reason: nil, additional_withdraw_reason: nil, withdraw_date: nil)
end
```

## Error code on DQT trainee jobs

Sometimes the different jobs that send trainee info to DQT (such as `Dqt::UpdateTraineeJob`) will produce an error. You can view these failed jobs in the Sidekiq UI. Some common errors:

### 500 error

This is a cloud server error. You can usually just rerun these jobs and they'll succeed. If not, speak with DQT about the trainee.

### 404 error

This is triggered when DQT cannot find the trainee. We've seen this happen when there is a mismatch on the Date of Birth (we send both TRN and DOB to DQT to match trainees). Speak with the DQT team to align the date of birth if possible, then rerun.

### 400 error

This error means there is an unprocessable entry. This normally means there is some kind of validation error in the payload which will need to be investigated.