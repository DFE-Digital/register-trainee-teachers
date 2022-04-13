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