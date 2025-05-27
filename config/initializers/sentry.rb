# frozen_string_literal: true

Sentry.init do |config|
  filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
  config.before_send = lambda do |event, _hint|
    filter.filter(event.to_hash)
  end

  # NOTE: turn off Sentry Cron monitoring it seems to automatically create new monitor without notice
  # https://dfe-teacher-services.sentry.io/crons/
  # config.enabled_patches += [:sidekiq_cron]

  config.traces_sample_rate = 0.05
  config.profiles_sample_rate = 0.05
  config.release = ENV.fetch("COMMIT_SHA", nil)

  config.sdk_logger.level = Logger::INFO
end
