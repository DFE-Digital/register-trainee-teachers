# frozen_string_literal: true

module FundingHelper
  def funding_options(trainee)
    cannot_start_funding?(trainee) ? :funding_inactive : :funding_active
  end

private

  def cannot_start_funding?(trainee)
    CalculateBursary.available_for_route?(trainee.training_route.to_sym) &&
      trainee.course_subject_one.blank?
  end
end
