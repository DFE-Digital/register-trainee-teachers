# frozen_string_literal: true

class PerformanceProfileBanner::ViewPreview < ViewComponent::Preview
  def census_period
    render(PerformanceProfileBanner::View.new(previous_academic_cycle: AcademicCycle.previous, sign_off_period: :census_period, provider: provider_awaiting_sign_off))
  end

  def outside_period
    render(PerformanceProfileBanner::View.new(previous_academic_cycle: AcademicCycle.previous, sign_off_period: :outside_period, provider: provider_awaiting_sign_off))
  end

  def performance_period_signed_off
    render(PerformanceProfileBanner::View.new(previous_academic_cycle: AcademicCycle.previous, sign_off_period: :performance_period, provider: provider_performance_signed_off))
  end

  def performance_period_awaiting_sign_off
    render(PerformanceProfileBanner::View.new(previous_academic_cycle: AcademicCycle.previous, sign_off_period: :performance_period, provider: provider_awaiting_sign_off))
  end

private

  def provider_awaiting_sign_off
    OpenStruct.new(performance_profile_awaiting_sign_off?: true)
  end

  def provider_performance_signed_off
    OpenStruct.new(performance_profile_awaiting_sign_off?: false)
  end
end
