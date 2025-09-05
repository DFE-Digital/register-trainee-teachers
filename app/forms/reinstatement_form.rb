# frozen_string_literal: true

class ReinstatementForm < MultiDateForm
  include CourseFormHelpers

  validate :date_valid

private

  def assign_attributes_to_trainee
    trainee[date_field] = date
    trainee.trainee_start_date = date if trainee.deferred? && trainee.trainee_start_date.nil?
    clear_funding_information
  end

  def date_field
    @date_field ||= :reinstate_date
  end
end
