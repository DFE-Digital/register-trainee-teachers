# frozen_string_literal: true

Sentry.init do |config|
  # NOTE: turn off Sentry Cron monitoring it seems to automatically create new monitor without notice
  # https://dfe-teacher-services.sentry.io/crons/
  # config.enabled_patches += [:sidekiq_cron]

  filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
  config.before_send = lambda do |event, _hint|
    event.extra = filter.filter(event.extra) if event.extra
    event.user = filter.filter(event.user) if event.user
    event.contexts = filter.filter(event.contexts) if event.contexts
    event
  end

  config.traces_sample_rate = 0.05
  config.profiles_sample_rate = 0.05
  config.release = ENV.fetch("COMMIT_SHA", nil)

  config.sdk_logger.level = Logger::INFO
end
