# frozen_string_literal: true

class OtpForm
  include ActiveModel::Model
  include ThrottleRequests

  attr_reader :email

  validates :email, presence: true, length: { maximum: 255 }
  validate do |record|
    ::EmailFormatValidator.new(record).validate if email.present?
  end
  validate :rate_limit, if: -> { errors.empty? }

  def initialize(session:, email:)
    @session = session
    @email = email&.strip

    super(session:)
  end

  def raise_throttle_error
    errors.add(:email, cool_down_message)
  end

private

  def rate_limit
    return unless EmailRateLimiter.call(email:)

    errors.add(:email, "Please wait #{time_ago_in_words(Settings.otp.throttling.interval.to_i.seconds.from_now)} before trying again")
  end
end
