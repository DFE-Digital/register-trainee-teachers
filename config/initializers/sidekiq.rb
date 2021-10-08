# frozen_string_literal: true

if ENV.key?("VCAP_SERVICES")
  service_config = JSON.parse(ENV["VCAP_SERVICES"])
  redis_config = service_config["redis"]
  redis_worker_config = redis_config.select { |r| r["instance_name"].include?("worker") }.first
  redis_credentials = redis_worker_config["credentials"]

  Sidekiq.configure_server do |config|
    config.redis = {
      url: redis_credentials["uri"],
    }

    if Settings.bg_jobs
      Sidekiq::Cron::Job.load_from_hash(Settings.bg_jobs)
    end
  end

  Sidekiq.configure_client do |config|
    config.redis = {
      url: redis_credentials["uri"],
    }
  end
end

# Sidekiq Cron
if Settings.sidekiq.schedule_file && Sidekiq.server?
  Sidekiq::Cron::Job.load_from_hash(YAML.load_file(Settings.sidekiq.schedule_file))
end
