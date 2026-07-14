# frozen_string_literal: true

class OtpForm
  include ActiveModel::Model
  include ActionView::Helpers::DateHelper

  attr_reader :email

  validates :email, presence: true, length: { maximum: 255 }
  validate do |record|
    ::EmailFormatValidator.new(record).validate if email.present?
  end
  validate :rate_limit, if: -> { errors.empty? }

  def initialize(email:)
    @email = email&.strip
  end

private

  def rate_limit
    return unless EmailRateLimiter.call(email: email, scope: :requests)

    errors.add(:email, "Please wait #{time_ago_in_words(Settings.otp.throttling.requests.interval.to_i.seconds.from_now)} before trying again")
  end
end
