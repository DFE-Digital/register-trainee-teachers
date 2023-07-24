![build](https://github.com/DFE-Digital/register-trainee-teachers/workflows/build/badge.svg)
![Deploy to PaaS](https://github.com/DFE-Digital/register-trainee-teachers/workflows/Deploy%20to%20PaaS/badge.svg)
[![View performance data on Skylight](https://badges.skylight.io/status/YttDFt8jHcNT.svg?token=nRTIRMZsne7UqkwqgjCsuh0cT1z572MKKiBtrea6tFA)](https://www.skylight.io/app/applications/YttDFt8jHcNT)

# Register trainee teachers

A service for training providers in England to register trainees with the Department for Education and record the outcome of their training.

## Development

### Install build dependencies

The required versions of build tools is defined in
[.tool-versions](.tool-versions). These can be automatically installed with
[asdf-vm](https://asdf-vm.com/), see their [installation
instructions](https://asdf-vm.com/#/core-manage-asdf).

Once installed, run:

```bash
asdf plugin add ruby
asdf plugin add nodejs
asdf plugin add yarn
asdf install
```

When the versions are updated on the `main` branch run `asdf install` again to update your
installation. Use `asdf plugin update --all` to update plugins and get access to
newer versions of tools.

## Setting up the app in development

1. Run `bundle install` to install the gem dependencies
2. Run `yarn` to install node dependencies
3. Run `bin/rails db:setup` to set up the database development and test schemas, and seed with test data
4. Add a file to config/settings called development.local.yml containing the following:

   ```yml
       features:
         use_ssl: false
   ```

5. Run `bundle exec rails server` to launch the app on http://localhost:5000
6. Run `./bin/webpack-dev-server` in a separate shell for faster compilation of assets

### Setting up seed records

#### Using a Dev persona (optional)

This will allow you to create a dev persona with your own email address - useful for when testing mailers/notify.

create the file `config/initializers/developer_persona.rb` and add your own credentials in the format:

```ruby
DEVELOPER_PERSONA = { first_name: "first", last_name: "last", email: "first.last@education.gov.uk", system_admin: true }.freeze
```

#### Seeding

Run `rake example_data:generate` to generate seed records.
If you have created a dev persona, this wil be included when generating the persona profiles.


## Architectural Decision Record

See the [docs/adr](docs/adr) directory for a list of the Architectural Decision
Record (ADR). We use [adr-tools](https://github.com/npryce/adr-tools) to manage
our ADRs, see the link for how to install (hint: `brew install adr-tools` or use
ASDF).

## Testing
To ensure webpacker works for you when tests run:

```bash
RAILS_ENV=test bundle exec rails assets:precompile
```

Then you can run the full test suite with:

```bash
bundle exec rake
```

## Running specs

```bash
bundle exec rspec
```

### Running specs in parallel

When running specs in parallel for the first time you will first need to set up
your test databases.

`bundle exec rails parallel:setup`

To run the specs in parallel:
`bundle exec rails parallel:spec`

To drop the test databases:
`bundle exec rails parallel:drop`

You can see the full list of commands with: `bundle exec rails -T | grep parallel`

### rspec-retry

[rspec-retry](https://github.com/NoRedInk/rspec-retry) is a gem that handles
flakey tests by re-running failing tests a configurable number of times.

It can cause problems when running tests in a development environment due to
misleading error messages when specs (really) do fail. The workaround is to
configure the number of attempts to `1` so that no retries happen. Add this
line to `.env.test.local`:

```
RSPEC_RETRY_RETRY_COUNT: 1
```

## Linting

### Ruby

It's best to lint just your app directories and not those belonging to the framework:

```bash
bundle exec rails lint:ruby
```
or

```
docker-compose exec web /bin/sh -c "bundle exec rails lint:ruby"
```

To fix Rubocop issues:

```
bundle exec rubocop -a app config db lib spec --format clang
```

### JavaScript

To lint the JavaScript files:

```
yarn standard
```

To fix JavaScript lint issues:

```
yarn run standard --fix
```

### SCSS

To lint the SCSS files:

```
bundle exec rails lint:scss
```

### Running all pre-build checks

```
bundle exec rake
```

## Secrets vs Settings

Refer to the [the config gem](https://github.com/railsconfig/config#accessing-the-settings-object) to understand the `file based settings` loading order.

To override file based via `Machine based env variables settings`

```bash
cat config/settings.yml
file
  based
    settings
      env1: 'foo'
```

```bash
export SETTINGS__FILE__BASED__SETTINGS__ENV1="bar"
```

```ruby
puts Settings.file.based.setting.env1

bar
```

Refer to the [settings file](config/settings.yml) for all the settings required to run this app

## Resetting Secrets and passwords

Please visit the [confluence page](https://dfedigital.atlassian.net/wiki/spaces/BaT/pages/2351824901/Resetting+Secrets+for+Register-Trainee-Teachers) for instructions

## Feature flags

This repo supports the ability to set up feature flags. To do this, add your feature flag in the [settings file](config/settings.yml) under the `features` property. eg:

```yaml
features:
  some_feature: true
```

You can then use the [feature service](app/services/feature_service.rb) to check whether the feature is enabled or not. Eg. `FeatureService.enabled?(:some_feature)`.

You can also nest features:

```yaml
features:
  some:
    nested_feature: true
```

And check with `FeatureService.enabled?("some.nested_feature")`.

### Testing with features

Rspec tests can also be tagged with `feature_{name}: true`. This will turn that feature on just for the duration of that test.

## Basic auth

Basic auth is enabled in non-production and non-local environments. The credentials can be found in the Confluence pages.

## SSL https local dev

When running the https local dev environment if you are on Mac and using Chrome you may need to get past an invalid certificate screen. <https://stackoverflow.com/questions/58802767/no-proceed-anyway-option-on-neterr-cert-invalid-in-chrome-on-macos>

### DfE Sign-in

For DfE Signin to work, the below values needs to be set.

```yml
base_url: base_url required value
features:
  use_dfe_sign_in: true
dfe_sign_in:
  identifier: identifier required value
  issuer: issuer required value
  profile: profile required value
  secret: secret required value

```

### Hosting

Register is hosted on [GOVUK PAAS](https://www.cloud.service.gov.uk/)

[Additional GOVUK PAAS documentation](docs/govuk_paas.md)

## DTTP settings for testing

Add the following settings to your `development.yml.local` (ask a team member for the secrets):

```yaml
dttp:
  client_id: SECRET
  client_secret: SECRET
  tenant_id: SECRET
  scope: "https://dttp-dev.crm4.dynamics.com/.default"
  api_base_url: "https://dttp-dev.api.crm4.dynamics.com/api/data/v9.1"
```

## PaaS Space Access and App interaction

In order to login, change space roles and interact with PaaS based application,
please follow this [instruction](https://dfedigital.atlassian.net/wiki/spaces/BaT/pages/2409791489/Changing+set+and+unset+roles+and+interacting+with+App+on+PaaS)

## School data
[Get Information about Schools](https://get-information-schools.service.gov.uk) holds the most complete information for schools.

In order to create and update the  schools follow the below steps
1. [Download Get Information about Schools data](#download-get-information-about-schools-data)
2. [Generate data/schools_gias.csv from GIAS data](#generate-dataschools_giascsv-from-gias-data)
3. [Import schools from csv data/schools_gias.cs](#import-schools-from-csv-dataschools_giascsv)
4. [Generate data/lead_schools_publish.csv from Publish api](#generate-datalead_schools_publishcsv-from-publish-api)

### Download Get Information about Schools data
1. Go to [Get Information about Schools Download page](https://get-information-schools.service.gov.uk/Downloads)
2. From `Open academies and free schools data` select `Academies and free school fields CSV`
3. From `Open state-funded schools data` select `State-funded school fields CSV`
4. Click on `Download selected files`
5. Extract content to `./data` directory

### Generate data/schools_gias.csv from GIAS data
To generate the data/schools_gias.csv from GIAS data, use the following rake task:

```bash

# gias_csv_1_path: path to the GIAS file
# gias_csv_2_path: path to the GIAS file
# output_path: optional, path to the output file, default to `data/schools_gias.csv`
bundle exec rake schools_data:generate_csv_from_gias\[gias_csv_1_path,gias_csv_2_path,output_path\]

# as an example
bundle exec rake schools_data:generate_csv_from_gias\[./data/edubaseallacademiesandfree20230719.csv,./data/edubaseallstatefunded20230719.csv\]

```

### Import schools from csv data/schools_gias.csv
To import schools from csv data/schools_gias.csv, use the following rake task:

```bash
bundle exec rake schools_data:import_gias
```

### Generate data/lead_schools_publish.csv from Publish api

To generate the data/lead_schools_publish.csv from Publish api data, use the following rake task:

```bash

# output_path: optional, path to the output file, default to `data/lead_schools_publish.csv`
bundle exec rake schools_data:generate_csv_from_publish\[output_path\]

# as an example
bundle exec rake schools_data:generate_csv_from_publish

```

## Running Apply application import against example data

Add the following to your `development.local.yml`:

```yml
features:
  import_applications_from_apply: true

apply_api:
  base_url: "https://sandbox.apply-for-teacher-training.service.gov.uk/register-api"
  auth_token: <request token from Apply team>
```

Running the following script:

```ruby
ApplyApi::ImportApplication.class_eval do
  def provider
    Provider.all.sample
  end
end
ApplyApplicationSyncRequest.delete_all
ApplyApi::ImportApplicationsJob.perform_now
```
