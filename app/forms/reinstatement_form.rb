# frozen_string_literal: true

class ReinstatementForm < MultiDateForm
  validate :date_valid

private

  def assign_attributes_to_trainee
    trainee[date_field] = date
    trainee.commencement_date = date if trainee.deferred? && trainee.commencement_date.nil?
  end

  def date_field
    @date_field ||= :reinstate_date
  end
end
