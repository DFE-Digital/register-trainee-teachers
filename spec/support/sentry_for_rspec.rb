# frozen_string_literal: true

module SentryForRSpec
  def self.report_retry(example, config)
    create_sentry_scope(example, config)

    Sentry.with_scope do |scope|
      create_tags(scope, example)
      send_message(example)
    end
  end

  def self.create_sentry_scope(example, config)
    Sentry.configure_scope do |scope|
      scope.set_context(
        "RSpec",
        { test_name: example.metadata[:description],
          test_description: example.metadata[:full_description],
          location: example.metadata[:location],
          failure: example.metadata[:retry_exceptions],
          retry_attempt: example.metadata[:retry_attempts],
          seed: config.seed },
      )
    end
  end

  def self.create_tags(scope, example)
    scope.set_tags(location: example.metadata[:location].to_s)
  end

  def self.send_message(example)
    Sentry.capture_message("RSpec test retry at #{example.metadata[:location]}", fingerprint: [example.metadata[:location]])
  end
end
