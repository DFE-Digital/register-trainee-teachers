# frozen_string_literal: true

class WithdrawalForm
  include ActiveModel::Model
  include ActiveModel::AttributeAssignment
  include ActiveModel::Validations::Callbacks

  attr_accessor :trainee, :day, :month, :year, :withdraw_date_string, :withdraw_reason, :additional_withdraw_reason

  delegate :id, :persisted?, to: :trainee

  validate :withdraw_date_valid
  validate :withdraw_reason_valid
  validate :additional_withdraw_reason_valid

  after_validation :update_trainee, if: -> { errors.empty? }

  def initialize(trainee)
    @trainee = trainee
    super(fields)
  end

  def fields
    {
      withdraw_date_string: rehydrate_withdraw_date_string,
      day: trainee.withdraw_date&.day,
      month: trainee.withdraw_date&.month,
      year: trainee.withdraw_date&.year,
      withdraw_reason: trainee.withdraw_reason,
      additional_withdraw_reason: trainee.additional_withdraw_reason,
    }
  end

  def save
    valid? && trainee.save
  end

  def withdraw_date
    date_conversion[withdraw_date_string]
  end

private

  def for_another_reason?
    withdraw_reason == WithdrawalReasons::FOR_ANOTHER_REASON
  end

  def rehydrate_withdraw_date_string
    return unless trainee.withdraw_date

    case trainee.withdraw_date
    when Time.zone.today
      "today"
    when Time.zone.yesterday
      "yesterday"
    else
      "other"
    end
  end

  def update_trainee
    trainee.assign_attributes({
      withdraw_date: withdraw_date,
      withdraw_reason: withdraw_reason,
      additional_withdraw_reason: for_another_reason? ? additional_withdraw_reason : nil,
    })
  end

  def date_conversion
    {
      today: Time.zone.today,
      yesterday: Time.zone.yesterday,
      other: other_date,
    }.with_indifferent_access
  end

  def other_date
    date_hash = { year: year, month: month, day: day }
    date_args = date_hash.values.map(&:to_i)

    Date.valid_date?(*date_args) ? Date.new(*date_args) : OpenStruct.new(date_hash)
  end

  def withdraw_date_valid
    if withdraw_date_string.nil?
      errors.add(:withdraw_date_string, :blank)
    elsif withdraw_date_string == "other" && [day, month, year].all?(&:blank?)
      errors.add(:withdraw_date, :blank)
    elsif !withdraw_date.is_a?(Date)
      errors.add(:withdraw_date, :invalid)
    end
  end

  def withdraw_reason_valid
    errors.add(:withdraw_reason, :invalid) if withdraw_reason.blank?
  end

  def additional_withdraw_reason_valid
    errors.add(:additional_withdraw_reason, :blank) if for_another_reason? && additional_withdraw_reason.blank?
  end
end
