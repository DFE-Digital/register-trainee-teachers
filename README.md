![build](https://github.com/DFE-Digital/register-trainee-teachers/workflows/build/badge.svg)
![Deploy to PaaS](https://github.com/DFE-Digital/register-trainee-teachers/workflows/Deploy%20to%20PaaS/badge.svg)
[![View performance data on Skylight](https://badges.skylight.io/status/YttDFt8jHcNT.svg?token=nRTIRMZsne7UqkwqgjCsuh0cT1z572MKKiBtrea6tFA)](https://www.skylight.io/app/applications/YttDFt8jHcNT)

# Register trainee teachers

## Development

### Install build dependencies

The required versions of build tools is defined in
[.tool-versions](.tool-versions). These can be automatically installed with
[asdf-vm](https://asdf-vm.com/), see their [installation
instructions](https://asdf-vm.com/#/core-manage-asdf).

Once installed, run:

```
asdf plugin add ruby
asdf plugin add nodejs
asdf plugin add yarn
asdf install
```

When the versions are updated on the `main` branch run `asdf install` again to update your
installation. Use `asdf plugin update --all` to update plugins and get access to
newer versions of tools.

### Install GraphViz

This is not essential if you just want to run the app. However, if you're
intending to make any changes to the database schema, this is a requirement
for [rails-erd](https://github.com/voormedia/rails-erd).

```
brew install graphviz
```

## Setting up the app in development

1. Run `bundle install` to install the gem dependencies
2. Run `yarn` to install node dependencies
3. Run `bin/rails db:setup` to set up the database development and test schemas, and seed with test data
4. Run `bundle exec rails server` to launch the app on http://localhost:3000
5. Run `./bin/webpack-dev-server` in a separate shell for faster compilation of assets

### Setting up seed records

Run `rake example_data:generate` to generate seed records

## Architectural Decision Record

See the [docs/adr](docs/adr) directory for a list of the Architectural Decision
Record (ADR). We use [adr-tools](https://github.com/npryce/adr-tools) to manage
our ADRs, see the link for how to install (hint: `brew install adr-tools` or use
ASDF).

## Running specs, linter(without auto correct) and annotate models and serializers

```
bundle exec rake
```

## Running specs

```
bundle exec rspec
```

## Linting

It's best to lint just your app directories and not those belonging to the framework, e.g.

```bash
bundle exec rubocop app config db lib spec Gemfile --format clang -a

or

bundle exec scss-lint app/webpacker/styles
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

When running the https local dev environment if you are on Mac and using Chrome you may need to get past an invalid certificate screen. https://stackoverflow.com/questions/58802767/no-proceed-anyway-option-on-neterr-cert-invalid-in-chrome-on-macos

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
In order to login, change space roles and interact with PaaS based application, please follow this [instruction] https://dfedigital.atlassian.net/wiki/spaces/BaT/pages/2409791489/Changing+set+and+unset+roles+and+interacting+with+App+on+PaaS

### Generating schools data
To create/update schools data, we do this using a rake task:
```
bundle exec rake schools_data:import
```
which reads from a csv located in `data/schools.csv`. This will create
any new schools that aren't in the database, or update existing ones
based on the urn.

## Regenerating data/schools.csv

if required, the `data/schools.csv` can be regenerated using this rake
task (if school details update, or there is a new list of lead schools
for the coming year.

```
bundle exec rake schools_data:generate_csv[establishment_csv_path, lead_schools_csv_path]
```
The establisment csv can be downloaded here https://get-information-schools.service.gov.uk/Downloads
under "Establishment fields".

To create the lead schools csv, there is a spreadsheet in google drive: https://drive.google.com/file/d/1ziI5x4oSqXCUaG5q_8-VXiMzDWOVlIiC/view

The second tab: "MASTER LIST_All Lead Schools" must be exported as a csv.

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
```
ApplyApi::ImportApplication.class_eval do
  def provider
    Provider.all.sample
  end
end
ApplyApplicationSyncRequest.delete_all
ApplyApi::ImportApplicationsJob.perform_now
```