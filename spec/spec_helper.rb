# frozen_string_literal: true

require "rspec/retry"
require "rspec-benchmark"

if ENV.fetch("COVERAGE", false)
  require "simplecov"

  SimpleCov.coverage_dir("coverage/backend")
  SimpleCov.minimum_coverage(90)
  SimpleCov.start("rails") do
    add_filter %r{/code_sets/}
  end

  # If running specs in parallel this ensures SimpleCov results appears
  # upon completion of all specs
  if ENV["TEST_ENV_NUMBER"]
    SimpleCov.at_exit do
      result = SimpleCov.result
      result.format! if ParallelTests.number_of_running_processes <= 1
    end
  end
end

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers

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
  end

  use_next_academic_year = ENV.fetch("USE_NEXT_ACADEMIC_YEAR", false) == "true"

  pp "USE_NEXT_ACADEMIC_YEAR=#{use_next_academic_year}"
  config.around do |example|
    if use_next_academic_year
      Timecop.travel(current_academic_year + 1, 8, 1) do
        example.run
      end
    else
      example.run
    end
  end

  config.after do
    Timecop.return if use_next_academic_year
  end
end
