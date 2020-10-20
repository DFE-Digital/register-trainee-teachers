if ENV.fetch("COVERAGE", false)
  require "simplecov"

  SimpleCov.coverage_dir("coverage/backend")
  SimpleCov.minimum_coverage(80)
  SimpleCov.start("rails")
end

RSpec.configure do |config|
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

  config.profile_examples = 3

  config.order = :random

  config.shared_context_metadata_behavior = :apply_to_host_groups
end
