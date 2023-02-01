# Testing Data Migrations

Data migrations can/should be tested using production data. To download a copy from production:

1. Request production access in [#twd_regsiter_devs](https://ukgovernmentdfe.slack.com/archives/C03SR5B5EGH)
   noting why you need it.
2. Log in:
   `cf login -a https://api.london.cloud.service.gov.uk --sso`
3. Set space to:
   `bat-prod`
4. Make sure conduit is installed:
   `cf install-plugin conduit`
5. Download the db:
   `cf conduit register-postgres-13-production -- pg_dump -f register-postgres-production.sql --no-acl --no-owner --clean`
6. Then import:
   `DISABLE_DATABASE_ENVIRONMENT_CHECK=1 rake db:{drop,create} && psql register_trainee_teacher_data_development < register-postgres-production.sql`
7. This will have overwritten any migrations you have created for the feature you are working on, if so run
   `bundle exec rails db:migrate`
8. Finally, **ensure the psql dump is deleted once testing is complete**.
