# frozen_string_literal: true

class OutcomeDateForm < MultiDateForm
  validate :date_valid
  validate :date_is_not_in_future

private

  def date_field
    @date_field ||= :outcome_date
  end

  def date_is_not_in_future
    if date_string == "other" && date.future?
      errors.add(:date, :future)
    end
  end
end
