# Testing Data Migrations

Data migrations can/should be tested using production data. To download a copy from production:

1. `cf login -a https://api.london.cloud.service.gov.uk --sso`
2. Set space to `bat-prod`
3. Make sure conduit is installed `cf install-plugin conduit`
4. Download the db `cf conduit register-postgres-13-production -- pg_dump -f register-postgres-production.sql --no-acl --no-owner --clean`
5. Then import `DISABLE_DATABASE_ENVIRONMENT_CHECK=1 rake db:reset && psql register_trainee_teacher_data_development < register-postgres-production.sql`
6. Finally, **ensure the psql dump is deleted once testing is complete**.
