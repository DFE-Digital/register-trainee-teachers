# frozen_string_literal: true

class CensusBanner::ViewPreview < ViewComponent::Preview
  def census_period
    render(CensusBanner::View.new(current_academic_cycle: AcademicCycle.previous, sign_off_period: :census_period, provider: provider_awaiting_sign_off))
  end

  def outside_period
    render(CensusBanner::View.new(current_academic_cycle: AcademicCycle.previous, sign_off_period: :outside_period, provider: provider_awaiting_sign_off))
  end

  def census_signed_off
    render(CensusBanner::View.new(current_academic_cycle: AcademicCycle.previous, sign_off_period: :census_period, provider: provider_census_signed_off))
  end

  def census_awaiting_sign_off
    render(CensusBanner::View.new(current_academic_cycle: AcademicCycle.previous, sign_off_period: :census_period, provider: provider_awaiting_sign_off))
  end

private

  def provider_awaiting_sign_off
    OpenStruct.new(census_signed_off?: false)
  end

  def provider_census_signed_off
    OpenStruct.new(census_signed_off?: true)
  end
end
