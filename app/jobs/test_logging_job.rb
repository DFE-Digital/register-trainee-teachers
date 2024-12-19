# frozen_string_literal: true

class TestLoggingJob < ApplicationJob
  queue_as :default

  def perform
    # Info level logging
    Rails.logger.info("TestLoggingJob: Starting test logging job at #{Time.now.utc.iso8601}")

    # Simulate some work
    Rails.logger.info("TestLoggingJob: Performing some work...")

    # Generate an exception for testing error logging
    if rand < 0.5
      Rails.logger.info("TestLoggingJob: About to raise a test exception...")
      raise(StandardError, "This is a test exception for logging purposes")
    end

    Rails.logger.info("TestLoggingJob: Job completed successfully")
  rescue StandardError => e
    Rails.logger.error("An error occurred in TestLoggingJob: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    raise # Re-raise the exception to ensure it's properly reported
  end
end
