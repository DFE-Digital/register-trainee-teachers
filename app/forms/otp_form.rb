# frozen_string_literal: true

class OtpForm
  include ActiveModel::Model

  validates :email, presence: true
  validate do |record|
    ::EmailFormatValidator.new(record).validate if email.present?
  end

  def initialize(email)
    @email = email&.strip
  end

  attr_reader :email
end
