# frozen_string_literal: true

# Block requests from IP blacklist
Rack::Attack.blocklist("block requests from IP blacklist") do |req|
  req.path.start_with?("/api") && req.ip.in?(Settings.api.blacklist.ip)
end

# Block requests from UA blacklist
Rack::Attack.blocklist("block requests from UA blacklist") do |req|
  req.path.start_with?("/api") && req.user_agent.in?(Settings.api.blacklist.ua)
end

# Throttle high volumes of API requests by IP address
unless Rails.env.local?
  Rack::Attack.throttle(
    "req/ip",
    limit: Settings.api.throttling.max_requests,
    period: Settings.api.throttling.interval.to_i.seconds,
  ) do |req|
    req.ip if req.path.starts_with?("/api")
  end
end

# Return how many seconds to wait before retrying request to well-behaved clients
Rack::Attack.throttled_response_retry_after_header = true
