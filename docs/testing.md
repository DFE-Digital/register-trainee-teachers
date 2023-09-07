# Testing & Linting

## Running specs

To ensure webpacker works for you when tests run:

```bash
RAILS_ENV=test bundle exec rails assets:precompile
```

Then you can run the full test suite with:

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

### Javascript specs

You can run the JS specs with:

```bash
yarn run test
```

### Testing with features

Rspec tests can also be tagged with `feature_{name}: true`. This will turn that feature on just for the duration of that test.


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

```shell
bundle exec rails lint:scss
```

## Running all pre-build checks

```
bundle exec rake
```
