# Support Playbook

## Making data changes

If you’re making a data change, you must include an `audit_comment` so that we can see why we did this. For example:

```ruby
trainee.update(date_of_birth: <whatevs>, audit_comment: 'Update from the trainee via TRS')
```

## Changing training route

Sometimes support will ask a dev to update the training route. Here is an example for updating a route to `school_direct_salaried`.

```ruby
trainee = Trainee.find_by(slug: "XXX")
manager = RouteDataManager.new(trainee: trainee)
manager.update_training_route!("school_direct_salaried")
```

A bunch of fields will be set to `nil`, see `RouteDataManager` class. Ask support to communicate with the user to update the Trainee record for the missing information.

`update_training_route!` no longer kicks off an update to TRS so that will need to be done manually if needed.

## Changing the withdrawal date for a withdrawn trainee

Sometimes support will ask a dev to change the withdrawal date for a trainee.

```ruby
trainee = Trainee.find_by(slug: "XXX")
trainee.current_withdrawal.update!(date: Date.new(2024, 3, 3), audit_comment: "Reason for changing the date")
```

## Unwithdrawing a withdrawn trainee

Sometimes support will ask a dev to unwithdraw a trainee which has been
withdrawn in error. When logged in as a system admin the trainee's withdrawal
can be reverted by clicking on `Undo withdrawal` at the `Withdrawal details`
section in the trainee show page `/trainees/:slug`

## Error codes on TRS trainee jobs

Sometimes the different jobs that send trainee info to TRS (such as
`Trs::UpdateTraineeJob` and `Trs::UpdateProfessionalStatus`) will produce an
error. You can view these failed jobs in the Sidekiq UI.

Sometimes a trainee will have both a failed update job, and a failed update
professional status job. In this case, make sure to re-run the update job
first. If you run the professional status job first and then try to run the
update job, the update will fail as the trainee will already have QTS (and
therefore can no longer be updated on TRS’s end).

We have a couple of services you can call which retrieve data about the trainee
in TRS.

If the trainee has a TRN already, call this (where `t` is the trainee):

```ruby
Trs::RetrieveTeacher.call(trainee: t)
```

This list is not exhaustive, but here are some common errors types that we see:

### 500 error

This is a cloud server error. You can usually just rerun these jobs and they’ll
succeed. If not, speak with the TRS team about the trainee.

### 404 error

This is triggered by `Trs::RetrieveTeacher` when TRS cannot find the trainee on their side.

```json
status: 404, body: {"title": "Person not found.", "status": 404, "detail": "TRN: '1234567890'","errorCode":10001}
```


and by `Trs::RetrieveTrnRequest` when TRS cannot find the TRN request on their side:

```json
status: 404, body: {"title": "TRN request does not exist.","status": 404, "detail": "TRN request ID: 'fe7711e7-5f0d-478a-9ce2-a9b1b9835c36'", "errorCode": 10031}
```

* You may also see this error come up when the trainee’s TRN is inactive on the TRS side

Speak with the TRS team to work out if it’s one of the above issues. Align the date of birth on both services and re-run the job.

### 400 error

This error means there is an unprocessable entry. This normally means there is
some kind of validation error in the payload which will need to be
investigated.

```json
status: 400, body: {"type":"https://tools.ietf.org/html/rfc9110#section-15.5.1","title":"One or more validation errors occurred.","status":400,"errors":{"holdsFrom":["Holds from date must be specified when status is 'Holds'."]}
```

* There might be a trainee state mismatch here between TRS and Register
* We’ve seen this error when a trainee has been withdrawn on TRS and awarded QTS on Register
* We have some known examples of trainees like this so it’s worth checking with our support team to see if there are existing comms about the trainee
* In this case you might need to check with the provider what the state of the record should be

```json
status: 400, body: {"title":"Teacher has no incomplete ITT record", "status":400, "errorCode":10005}
```

* If this error came from the changing status for QTS job, then the trainee might be stuck in change status for gaining QTS state
* If everything matches on TRS’s side (trainee details, the provider) then you may be able to just change the trainees’ QTS status on Register’s side
* If any doubt then check with the provider
* We’ve also seen this error on the withdraw job - cross-reference with TRS and check with provider if necessary to see what state the trainee should be in

```json
"qualification.providerUkprn":["Organisation not found"]
```

* We send the UKPRN of the trainee’s degree institution to TRS
* This error happens when TRS do not have a matching UKPRN on their end for the trainee’s degree organisation
* Locate the institution_uuid for the failing trainee and look up the UKPRN in the DfE Reference Data gem repo
* Send the UKPRN and degree institution details over to TRS so they can add on their side and re-run the job

```json
{"initialTeacherTraining.programmeType":["Teacher already has QTS/EYTS date"]}
```

* We’ve noticed there is likely a race condition sometimes causing this error
* When we run an award job, an update job is also kicked off
* We think that sometimes the award job succeeds before the update job, which causes this error on the update job
* Cross reference the trainee details on Register with the trainee details on TRS, you can use the TRS API for this - checking the trainee timeline on Register can also be helpful

  ```ruby
  Trs::RetrieveTeacher.call(trainee:)
  ```

* If there are no differences, it is likely a race condition and you can delete the failed update job
* If there are differences, speak to TRS and maybe contact provider to see what needs updating

### Trs::RetrieveTrnJob for Trainee id: xxx has timed out after 4 days

We see this error on slack when our polling job times out before we receive a
TRN from TRS. The default timeout is four days from the trainee’s
`submitted_for_trn_at` date.

We need to understand from TRS why the TRN is taking a while to assign. Is there
a problem we need to address?

If there is no issue, we can kick off another polling job with a timeout in the
future:

```ruby
Trs::RetrieveTrnJob.perform_later(t.dqt_trn_request, Date.today + 4.days)
```

### 500 error

Generally returned without a response body, often indicates a duplicate provider record on the TRS side. You'll need to liaise with the TRS team to resolve this.

### 503 error

May indicate that TRS is down.

```json
status: 503, body: {"type":"https://tools.ietf.org/html/rfc9110#section-15.6.4","title":"Service Unavailable","status":503,"traceId":"00-d25977e8c3bea5a9d8fcfd2041e1e4ae-229da0abb1de21bc-00"}

## Incorrectly awarded trainee

If a trainee has incorrectly had their status changed for QTS or EYTS in register this will also impact TRS.

In this scenario we must also contact TRS to fix the trainee status change and update the trainee status in register.

```ruby
trainee = Trainee.find_by(slug: "limax")

trainee.update(state: :trn_received, recommended_for_award_at: nil, awarded_at: nil, outcome_date: nil, audit_comment: 'fill in the blanks')
```

All record changes should be sent to TRS unless otherwise specified or impossible (for example, we cannot send a DOB update). If TRS already has that info (for example, they’re awarded on TRS, and we’re just awarding on Register) we should not send any information.

Register support may need to communicate with the trainee and provider to ensure that they understand the error and the resolution.

## Managing the Sidekiq queue

### via the UI

`system-admin/dead_jobs/` uses the methods below to list failed trainees. You can also download the list along with errors via `download (.csv)`.

### Console commands

#### Inspect jobs in a queue

```ruby
trs_queue = Sidekiq::Queue.new("dqt")
trs_queue.select { 1.value.include? "122803" } # select jobs containing user id value 122803
```

#### Tally by job type

```ruby
default_queue = Sidekiq::Queue.new("default")
default_queue.map { 1["wrapped"] }.tally
```

#### Dead jobs

```ruby
include Hashable

ds = Sidekiq::DeadSet.new

# unique user ids
ds.map { deep_dig(_1.args[0]["arguments"][0], "_aj_globalid").split("/").last }.uniq.count
# eg count 405 errors
ds.select { _1.item["error_message"].starts_with? "status: 405" }.count
# retry
ds.select { _1.item["error_message"].starts_with? "status: 405" }.map(&:retry)
```

## Settings

Sometimes we need to toggle/change features and settings. This can be done using the `kubectl set env` command. For example:

```sh
# set the ENV, the pods will automatically restart once the process has gone through
kubectl -n bat-production set env deployment/production SETTINGS__FEATURES__SIGN_IN_METHOD=otp
```

This process can take a short while, follow [Verifying settings has been changed](#verifying-settings-has-been-changed)

The format of the ENV you set is important. Double underscores `__` are the equivalent of subsections in `settings.yml` so the above is equivalent to:

```yml
# config/settings.yml

features:
  sign_in_method: otp
```

### Verifying settings has been changed

To check how the process is going. Use `kubectl get pods`. For example:

```sh
# Check that the old pods now have a status showing `Terminating`` and the new ones show `Running``.
kubectl -n bat-production get pods
```

To check that the environment variable has ben set. Use `kubectl describe`

```sh
kubectl -n bat-production describe deployment/register-production
```

### Disable DfE Analytics

Previously `DfE Analytics` caused a exponential spike on system load, leading to the system becoming non-responsive, for a extended period of time, with the initial cause being a few days prior.

By setting the `send_data_to_big_query` to `false` it in turns set DfE Analytics’ `enable_analytics`.

This will disables DfE Analytics.

> A machine restart is required so either via a PR or via terminal `kubectl`.
> This stop all of `DfE Analytics`.

```yml
# config/settings.yml
# config/settings/production.yml
features:
  google:
    send_data_to_big_query: false
```

```sh
# set the ENV, the pods will automatically restart once the process has gone through
kubectl -n bat-production set env deployment/production SETTINGS__FEATURES__GOOGLE__SEND_DATA_TO_BIG_QUERY=false
```

### Removing Duplicate Trainees

The `trainee:remove_duplicates` task is used to remove duplicate trainees from the database based on email address. The task requires a CSV file with trainee IDs as input.

Here’s how to use it:

**Syntax:**

```
rake trainee:remove_duplicates <path_to_csv_file>
```

**Parameters:**

* `path_to_csv_file`: This should be replaced with the path to the CSV file that contains the trainee IDs. The CSV file should contain a header row with an “trainee_id” and an “email” field. See below:

```csv
trainee_id,email
123,duplicate@example.com
456,duplicate@example.com
789,duplicate@example.com
890,unique@example.com
```

**Example:**

Suppose you have a CSV file named `trainees.csv` in the root directory of your project. To run the Rake task, you would use:

```
bundle exec rake trainee:remove_duplicates\[trainees.csv\]
```

This command will:

1. Open the `trainees.csv` file.
2. Run through each row, using the “id” field to find the corresponding trainee in the database.
3. If found, it will find and discard any other trainee that has the same email address.
4. If not found, it will print a message stating that the trainee was not found.
5. Once the task finishes running through all rows in the CSV, it will print “Task completed.”

## Resolving Incorrect `provider_type` on Publish: Ensuring Trainees are Created on Register

**Steps to Take:**

1. **Correct the `provider_type` on Publish**
    * Once the provider type is corrected, the Apply applications will be imported, and new trainees will be created.
2. **Identify the `apply_id` on Register**
    * Retrieve the `apply_id` from the `ApplyApplication` table using the following query:

      ```ruby
      application_choice_ids = ApplyApplication.where(accredited_body_code: "2N2", recruitment_cycle_year: 2024, state: :non_importable_hei).pluck(:apply_id)
      ```

3. **Touch All Relevant `ApplicationChoice` Entries on Apply**

    * Touch the relevant `ApplicationChoice` records so that when Register calls the API endpoint with the `changed_since` parameter it will return the applications again:

      ```ruby
      ApplicationChoice.where(id: application_choice_ids).touch_all
      ```

4. **Delete Related `ApplyApplication` Entries on Register**

    * Remove the associated `ApplyApplication` records from the Register:

      ```ruby
      ApplyApplication.where(apply_id: application_choice_ids).delete_all
      ```

5. **Initiate Sidekiq Jobs on Register**
    * Trigger the following Sidekiq jobs to complete the process:
      * `import_applications_from_apply`
      * `create_trainees_from_apply`

Note: This process will import a fresh copy of the applicants’ details and use them to create new records. This ensures that the system realigns with its normal mode of operation, correcting any issues caused by previously imported, potentially stale data.

## Training partners

### Converting a provider into training partner

If a provider loses accreditation and needs to be converted into a training partner, do the following

* Find the ids of all providers that need to be converted
* run the following task including the apostrophes

```
bundle exec rails 'copy_providers_to_lead_partners:copy[<provider ids separated by spaces>, <provider type, eg hei or scitt>]'
```

This task should create the new training partner and associate the providers' users with the new training partner record.

### Creating a training partner from a school

Ensure that the schools data are up to date see docs/setup-development.md

There is UI that the support agent that can use, so no need for a dev.

1. Find the school in question, <https://www.register-trainee-teachers.service.gov.uk/system-admin/schools>
2. Change `Is a training partner?` from `No` to `Yes`
3. Confirm it
4. Verify it, <https://www.register-trainee-teachers.service.gov.uk/system-admin/training-partners>

### Adding a previous trainee for a former accredited provider

Given a training partner and the former accredited provider is the same.

```ruby

lead_partner = LeadPartner.find(1363)

lead_partner.name == lead_partner.provider.name && lead_partner.provider.accredited? == false

trainee = Trainee.new(provider: lead_partner.provider, state: :draft)
```

Create a `draft` trainee for `lead_partner.provider` and ask the support agent to liaise with the provider to ensure that the details are correct, and the dates are correct.

May need overseeing from `draft` to `awarded`.

## Maintenance mode

If we need to put the system into maintenance mode, we can do so by running the
`Set maintenance mode` Github action. This can be run on `production`,
`staging` or `qa`. Maintenance mode consists of a simple static page, the
source for which can be found in the main repository under `maintenance/html`.
