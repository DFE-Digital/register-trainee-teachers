# frozen_string_literal: true

module PerformanceProfileBanner
  class View < ViewComponent::Base
    DEFAULT_ACADEMIC_CYCLE_START_DATE = "1 August"

    def initialize(previous_academic_cycle: AcademicCycle.previous, sign_off_period: DetermineSignOffPeriod.call, provider:)
      @previous_academic_cycle = previous_academic_cycle
      @provider = provider
      @sign_off_period = sign_off_period
    end

    def render?
      performance_period? && provider_awaiting_sign_off?
    end

    def banner_heading_text
      "The #{previous_academic_cycle_label} ITT performance profile sign off due"
    end

    delegate :label, :end_year, to: :previous_academic_cycle, prefix: true

    def deadline_date
      "28 February #{previous_academic_cycle_end_year + 1}"
    end

  private

    attr_reader :previous_academic_cycle, :provider, :sign_off_period

    def provider_awaiting_sign_off?
      !provider.performance_profile_signed_off?
    end

    def performance_period?
      sign_off_period == :performance_period
    end
  end
end
