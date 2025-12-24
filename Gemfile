# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.4.2"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 8.0"
gem "sprockets-rails"
gem "turbo-rails"

# Use postgresql as the database for Active Record
gem "pg", "~> 1.6"

# Use Puma as the app server
gem "puma", "~> 7.1"

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Data integration with BigQuery
gem "google-cloud-bigquery"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.1.0", require: false

# Manage multiple processes i.e. web server, redis, css/js builds
gem "foreman"

# Canonical meta tag
gem "canonical-rails"

# For determining file encoding
gem "charlock_holmes", "0.7.9"

# Soft delete records
gem "discard", "~> 1.4"

# Sentry
gem "sentry-rails"
gem "sentry-ruby"
gem "sentry-sidekiq"
gem "stackprof"

# Logging
gem "amazing_print", "~> 2.0"

gem "rails_semantic_logger", "~> 4.19.0"

# Thread-safe global state
gem "request_store", "~> 1.7"

# Used to build our forms and style them using govuk-frontend class names
gem "govuk-components"
gem "govuk_design_system_formbuilder"

# Background job processor
gem "sidekiq", "~> 6.5"
gem "sidekiq-cron", "~> 2.3"

# UK postcode parsing and validation for Ruby
gem "uk_postcode"

gem "config", "~> 5.6"

gem "httparty", "~> 0.24"

# Wrap jsonb columns with activemodel-like classes
gem "store_model", "~> 4.4"

gem "pundit"

# DfE Sign-in
gem "omniauth"
gem "omniauth_openid_connect"
gem "omniauth-rails_csrf_protection"

# OTP Sign-in
gem "base32"
gem "rotp"

# Full text search
gem "pg_search", "~> 2.3"

gem "slack-notifier"

# Tracking changes to models
gem "audited", "~> 5.8"

# Trainee state and transitions
gem "stateful_enum"

# Pagination
gem "kaminari"

gem "activerecord-session_store"
# Zip file extracting
gem "rubyzip"

# Monitoring
gem "prometheus-client"
gem "skylight"
gem "yabeda-prometheus"
gem "yabeda-rails"

# Run data migrations alongside schema migrations
gem "data_migrate", "11.3.1"

# Gov Notify
gem "govuk_notify_rails"

gem "blazer"

gem "auto_strip_attributes"

# Markdown
gem "front_matter_parser"
gem "govuk_markdown"

gem "mechanize" # interact with HESA

gem "dfe-reference-data", require: "dfe/reference_data", github: "DFE-Digital/dfe-reference-data", tag: "v3.8.6"

# for sending analytics data to the analytics platform
gem "dfe-analytics", github: "DFE-Digital/dfe-analytics", tag: "v1.15.13"

gem "ruby-progressbar" # useful for tracking long running rake tasks

gem "faraday"

gem "csv-safe"
gem "progress_bar" # useful to track progress of long running data migrations using scripts or rake tasks

gem "azure-blob"
gem "cssbundling-rails"
gem "jsbundling-rails"
gem "rack-attack"
gem "strong_migrations"

group :qa, :review, :staging, :production do
  # Pull list of CloudFront proxies so request.remote_ip returns the correct IP.
  gem "cloudfront-rails"
end

group :development, :test do
  gem "awesome_print"
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "byebug", platforms: %i[mri mingw x64_mingw]

  gem "erb_lint", require: false

  gem "rubocop-capybara"
  gem "rubocop-factory_bot"
  gem "rubocop-rails"
  gem "rubocop-rspec"
  gem "rubocop-rspec_rails"

  # Debugging
  gem "debug"
  gem "pry-byebug"

  # Better use of test helpers such as save_and_open_page/screenshot
  gem "launchy"

  gem "bullet"

  # Testing framework
  gem "rspec-rails", "~> 8.0.2"

  gem "rails-controller-testing"

  gem "rails-erd"

  # run specs in parallel
  gem "parallel_tests"
  gem "rspec-benchmark", require: false

  # Adds support for Capybara system testing and selenium driver
  gem "capybara", "~> 3.40"

  gem "dotenv-rails"

  gem "timecop", "~> 0.9.10"
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem "listen", ">= 3.0.5", "< 3.10"
  # gem "web-console", ">= 3.3.0"

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring"
  gem "spring-commands-rspec", "~> 1.0"
  gem "spring-watcher-listen", "~> 2.1.0"

  # Profiling
  gem "annotate"
  gem "benchmark-memory"
  gem "flamegraph"
  gem "memory_profiler"
  gem "rack-mini-profiler", require: false
end

group :test do
  # Headless browser testing kit
  gem "cuprite", "~> 0.17"
  gem "selenium-webdriver"

  gem "shoulda-matchers", "~> 7.0"
  # Code coverage reporter
  gem "simplecov", "~> 0.22.0", require: false
  gem "simplecov-json"

  # Page objects
  gem "site_prism", "~> 5.1"

  gem "webmock"

  # Clean out the database between tests
  gem "database_cleaner-active_record"

  gem "rspec-openapi"
  gem "rspec-retry"
end

# Required for example_data and vendor:transform so needed in stated environments
group :development, :test, :review, :qa, :audit, :sandbox do
  gem "bundle-audit", require: false
  gem "factory_bot_rails"
  gem "faker"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]

# Rails console colours
gem "colorize"
