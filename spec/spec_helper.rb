# frozen_string_literal: true

require "rspec-benchmark"
require "rspec/openapi"
require "simplecov"
require "simplecov-json"

SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::JSONFormatter,
])

if ENV.fetch("COVERAGE", false)
  SimpleCov.coverage_dir("coverage/backend")
  SimpleCov.start("rails") do
    add_filter "/spec/"
    add_filter %r{/code_sets/}
    enable_coverage :branch
  end
end

RSpec::Matchers.define_negated_matcher :not_change, :change

RSpec.configure do |config|
  config.before do
    RedisClient.current.flushdb
    Faker::Number.unique.clear
  end

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
    Timecop.return
  end
end
