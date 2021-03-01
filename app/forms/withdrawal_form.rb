# frozen_string_literal: true

class WithdrawalForm < MultiDateForm
  attr_accessor :withdraw_reason, :additional_withdraw_reason

  validate :withdraw_reason_valid
  validate :additional_withdraw_reason_valid

private

  def date_field
    @date_field ||= :withdraw_date
  end

  def additional_fields
    {
      withdraw_reason: trainee.withdraw_reason,
      additional_withdraw_reason: trainee.additional_withdraw_reason,
    }
  end

  def for_another_reason?
    withdraw_reason == WithdrawalReasons::FOR_ANOTHER_REASON
  end

  def update_trainee
    trainee.assign_attributes({
      withdraw_date: date,
      withdraw_reason: withdraw_reason,
      additional_withdraw_reason: for_another_reason? ? additional_withdraw_reason : nil,
    })
  end

  def withdraw_reason_valid
    errors.add(:withdraw_reason, :invalid) if withdraw_reason.blank?
  end

  def additional_withdraw_reason_valid
    errors.add(:additional_withdraw_reason, :blank) if for_another_reason? && additional_withdraw_reason.blank?
  end
end
