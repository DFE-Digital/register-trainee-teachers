# frozen_string_literal: true

require "rspec/retry"

if ENV.fetch("COVERAGE", false)
  require "simplecov"

  SimpleCov.coverage_dir("coverage/backend")
  SimpleCov.minimum_coverage(90)
  SimpleCov.start("rails") do
    add_filter %r{/code_sets/}
  end
end

RSpec.configure do |config|
  config.filter_run_excluding smoke: true

  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect
    mocks.verify_partial_doubles = true
  end

  if config.files_to_run.one?
    # Use the documentation formatter for detailed output,
    # unless a formatter has already been configured
    # (e.g. via a command-line flag).
    config.default_formatter = "doc"
  end

  config.filter_run_when_matching :focus

  config.profile_examples = 3

  config.order = :random

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.verbose_retry = true

  config.display_try_failure_messages = true

  config.around do |ex|
    ex.run_with_retry retry: 3
  end

  config.retry_callback = proc do |ex|
    if ex.metadata[:js]
      Capybara.reset!
    end

    # Allow Sentry to pick up messages triggered in our CI test build (and not locally).
    # Sends a warning when tests are retried so we can track indeterminate tests.
    if ENV.key?("SENTRY_DSN") && ex.metadata[:retry_exceptions]
      # Disable WebMock so we can send events to Sentry
      # Add sleep to avoid race condition
      WebMock.disable!
      sleep(3.seconds)
      SentryForRSpec.report_retry(ex, config)
      sleep(3.seconds)
      WebMock.enable!
      sleep(3.seconds)
      WebMock.disable_net_connect!(allow_localhost: true)
      sleep(3.seconds)
    end
  end
end
