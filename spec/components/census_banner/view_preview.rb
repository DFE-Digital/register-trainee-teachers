# frozen_string_literal: true

class CensusBanner::ViewPreview < ViewComponent::Preview
  def performance_profile_period
    render(CensusBanner::View.new(current_academic_cycle: AcademicCycle.current, sign_off_period: :perfomance_profile_period, provider: provider_awaiting_sign_off))
  end

  def outside_period
    render(CensusBanner::View.new(current_academic_cycle: AcademicCycle.current, sign_off_period: :outside_period, provider: provider_awaiting_sign_off))
  end

  def census_signed_off
    render(CensusBanner::View.new(current_academic_cycle: AcademicCycle.current, sign_off_period: :census_period, provider: provider_census_signed_off))
  end

  def census_awaiting_sign_off
    render(CensusBanner::View.new(current_academic_cycle: AcademicCycle.current, sign_off_period: :census_period, provider: provider_awaiting_sign_off))
  end

private

  def provider_awaiting_sign_off
    OpenStruct.new(census_awaiting_sign_off?: true)
  end

  def provider_census_signed_off
    OpenStruct.new(census_awaiting_sign_off?: false)
  end
end
