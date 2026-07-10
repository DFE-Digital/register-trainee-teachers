# frozen_string_literal: true

class EmailRateLimiter
  include ServicePattern

  def initialize(email:,
                 limit: Settings.otp.throttling.max_requests,
                 period: Settings.otp.throttling.interval.to_i.seconds)
    @email = email
    @limit = limit
    @period = period
  end

  # Returns true if the email has exceeded the allowed number of
  # requests within the period
  def call
    Rails.cache.increment(cache_key, 1, expires_in: period).to_i > limit
  end

private

  attr_reader :email, :limit, :period

  def cache_key
    "otp_requests:#{Digest::SHA256.hexdigest(email.downcase)}"
  end
end
