# frozen_string_literal: true

class EmailRateLimiter
  include ServicePattern

  def initialize(email:, scope:)
    @email = email
    @scope = scope
    @limit = Settings.otp.throttling[scope].max_requests
    @period = Settings.otp.throttling[scope].interval.to_i.seconds
  end

  # Returns true if the email has exceeded the allowed number of
  # attempts within the period
  def call
    Rails.cache.increment(cache_key, 1, expires_in: period).to_i > limit
  end

private

  attr_reader :email, :scope, :limit, :period

  def cache_key
    "otp_#{scope}:#{Digest::SHA256.hexdigest(email.downcase)}"
  end
end
