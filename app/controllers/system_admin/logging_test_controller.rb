# frozen_string_literal: true

module SystemAdmin
  class LoggingTestController < ApplicationController
    skip_before_action :authenticate

    def info
      Rails.logger.info("LoggingTestController: Info test at #{Time.now.utc.iso8601}")
      render json: { level: "info", time: Time.now.utc.iso8601 }
    end

    def warn
      Rails.logger.warn("LoggingTestController: Warning test at #{Time.now.utc.iso8601}")
      render json: { level: "warn", time: Time.now.utc.iso8601 }
    end

    def debug
      Rails.logger.debug("LoggingTestController: Debug test at #{Time.now.utc.iso8601}")
      render json: { level: "debug", time: Time.now.utc.iso8601 }
    end

    def error
      Rails.logger.error("LoggingTestController: Error test at #{Time.now.utc.iso8601}")
      render json: { level: "error", time: Time.now.utc.iso8601 }
    end

    def background_job
      TestLoggingJob.perform_later
      Rails.logger.info("LoggingTestController: Enqueued TestLoggingJob at #{Time.now.utc.iso8601}")
      render json: { status: "job_enqueued", time: Time.now.utc.iso8601 }
    end
  end
end
