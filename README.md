![build](https://github.com/DFE-Digital/register-trainee-teachers/workflows/build/badge.svg)
![Deploy to PaaS](https://github.com/DFE-Digital/register-trainee-teachers/workflows/Deploy%20to%20PaaS/badge.svg)

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

When the versions are updated in master run `asdf install` again to update your
installation. Use `asdf plugin update --all` to update plugins and get access to
newer versions of tools.

## Setting up the app in development

1. Run `bundle install` to install the gem dependencies
2. Run `yarn` to install node dependencies
3. Run `bin/rails db:setup` to set up the database development and test schemas, and seed with test data
4. Run `bundle exec rails server` to launch the app on http://localhost:3000
5. Run `./bin/webpack-dev-server` in a separate shell for faster compilation of assets

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
