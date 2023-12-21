# frozen_string_literal: true

class OtpForm
  include ActiveModel::Model
  include ThrottleRequests

  attr_reader :email

  validates :email, presence: true, length: { maximum: 255 }
  validate do |record|
    ::EmailFormatValidator.new(record).validate if email.present?
  end

  def initialize(session:, email:)
    @session = session
    @email = email&.strip

    super(session:)
  end

  def raise_throttle_error
    errors.add(:email, cool_down_message)
  end
end
