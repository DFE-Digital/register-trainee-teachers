# frozen_string_literal: true

module PerformanceProfileBanner
  class View < ApplicationComponent
    DEFAULT_ACADEMIC_CYCLE_START_DATE = "1 August"

    def initialize(previous_academic_cycle: AcademicCycle.previous, sign_off_period: DetermineSignOffPeriod.call, provider:)
      @previous_academic_cycle = previous_academic_cycle
      @provider = provider
      @sign_off_period = sign_off_period
    end

    def render?
      performance_period? && provider.performance_profile_awaiting_sign_off?
    end

    def banner_heading_text
      "The #{previous_academic_cycle_label} ITT performance profile sign off is due"
    end

    delegate :label, :end_date_of_performance_profile, to: :previous_academic_cycle, prefix: true

    def deadline_date
      previous_academic_cycle.end_date_of_performance_profile.strftime(Date::DATE_FORMATS[:govuk])
    end

  private

    attr_reader :previous_academic_cycle, :provider, :sign_off_period

    def performance_period?
      sign_off_period == :performance_period
    end
  end
end
