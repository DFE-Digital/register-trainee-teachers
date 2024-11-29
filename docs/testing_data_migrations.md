# Testing Data Migrations

Data migrations should be tested against production-like data.

1. Deploy to `productiondata`
2. Check that the deployment ran successfully and the data migration happened
3. Do any necessary checks on `productiondata` to ensure that the data has been changed as expected

## RSpec tests

Where a migration has logic beyond looping a list and updating records, it is good practice to include a service within
the migration and write a test for the service. An example is:

- [add_ethnicity_to_teach_first_trainees_spec.rb](../spec/data_migrations/add_ethnicity_to_teach_first_trainees_spec.rb)
- [20231214132713_add_ethnicity_to_teach_first_trainees.rb](../db/data/20231214132713_add_ethnicity_to_teach_first_trainees.rb)
