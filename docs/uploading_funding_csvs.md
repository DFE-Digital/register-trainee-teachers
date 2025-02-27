# Importing funding data from CSVs

## What is a trainee summary?

Trainee summaries contain (for each lead school or provider) the number of
trainees receiving different types of funding, split by training route and
subject.

## What is a payment schedule?

Payment schedules contain (for each lead school or provider) the total amount
of funding they are expected to receive each month, split by funding type.

Some of the months will contain actual amounts if funding has already been paid.
The rest will contain predicted amounts.

## Files we receive

Every month the funding team send us four funding-related CSVs. They will be
named something like this:

* `SDS_subject_breakdown_{Month}.csv`
  * The trainee summary for lead schools.
  * `rake funding:import_lead_school_trainee_summaries[csv_path]`
* `SDS_Profile_{Month}.csv`
  * The payment schedule for lead schools.
  * `rake funding:import_lead_school_payment_schedules[csv_path,first_predicted_month_index]`
* `TB_summary_upload_{Month}.csv`
  * The trainee summary for providers.
  * `rake funding:import_provider_trainee_summaries[csv_path]`
* `TB_Profile_{Month}.csv`
  * The payment schedule for providers.
  * `rake funding:import_provider_payment_schedules[csv_path,first_predicted_month_index]`

For the payment schedules, we will also be told which months contain predicted
values. If this is not clear, then reach out to the funding team to clarify.

## How to import the data

### Importing trainee summaries

1. Download the trainee summary file, for example, ‘SDS_subject_breakdown_January.csv’

2. Copy the CSV to your clipboard

    ```bash
    cat ~/Desktop/SDS_subject_breakdown_January.csv | pbcopy
    ```

3. Check that you’ve definitely copied the correct thing! Paste it somewhere

4. SSH onto register-worker-production, navigate into the app directory and
  create a new file

    ```bash
    kubectl -n bat-production exec -ti deployment/register-worker-production -- sh
    cd /app/tmp
    cat > funding.csv
    ```

5. Paste the contents of your clipboard into the file and exit

    ```bash
    cmd+v
    ctrl+c
    ```

6. Run the associated rake task

    ```bash
    bundle exec rake funding:import_lead_school_trainee_summaries['funding.csv']
    ```

7. Clean up after yourself!

    ```bash
    rm funding.csv
    ```

### Importing payment profiles

Follow the same steps as above, but run the payment schedule task:

  ```bash
  bundle exec rake funding:import_lead_school_payment_schedules['funding.csv',2]
  ```

The second argument is the first predicted month. For example, January = 1,
February = 2 etc.

### Gotchas

1. `TB_summary_upload_{Month}.csv` are received every 2 months (so do not expect to see one each time)
