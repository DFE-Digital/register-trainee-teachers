# frozen_string_literal: true

QUEUE_URL = ENV.fetch("REDIS_QUEUE_URL", nil)

Sidekiq.configure_server do |config|
  config.redis = {
    url: QUEUE_URL,
  }
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: QUEUE_URL,
  }
end

# Sidekiq Cron
if Settings.sidekiq.schedule_file && Sidekiq.server?
  Sidekiq::Cron::Job.load_from_hash!(YAML.load_file(Settings.sidekiq.schedule_file))
end
