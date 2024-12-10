# frozen_string_literal: true

if ENV.key?("VCAP_SERVICES")
  service_config = JSON.parse(ENV["VCAP_SERVICES"])
  redis_config = service_config["redis"]
  redis_worker_config = redis_config.select { |r| r["instance_name"].include?("worker") }.first
  redis_credentials = redis_worker_config["credentials"]
  queue_url = redis_credentials["uri"]
else
  queue_url = ENV.fetch("REDIS_QUEUE_URL", nil)
end

Sidekiq.configure_server do |config|
  config.redis = {
    url: queue_url,
  }
  config.logger = Rails.logger
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: queue_url,
  }
end

# Sidekiq Cron
if Settings.sidekiq.schedule_file && Sidekiq.server?
  Sidekiq::Cron::Job.load_from_hash!(YAML.load_file(Settings.sidekiq.schedule_file))
end
