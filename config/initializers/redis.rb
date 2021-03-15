# frozen_string_literal: true

if ENV.key?("VCAP_SERVICES")
  service_config = JSON.parse(ENV["VCAP_SERVICES"])
  redis_config = service_config["redis"].first
  redis_credentials = redis_config["credentials"]

  Redis.current = Redis.new(url: redis_credentials["uri"])
else
  Redis.current = Redis.new(url: ENV["REDIS_URL"])
end
