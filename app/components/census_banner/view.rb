# frozen_string_literal: true

module CensusBanner
  class View < ApplicationComponent
    def initialize(current_academic_cycle: AcademicCycle.current, sign_off_period: DetermineSignOffPeriod.call, provider:)
      @current_academic_cycle = current_academic_cycle
      @provider = provider
      @sign_off_period = sign_off_period
    end

    def render?
      census_period? && provider.census_awaiting_sign_off?
    end

    def banner_heading_text
      "The #{current_academic_cycle_label} ITT census sign off is due"
    end

    delegate :label, :itt_census_end_date, to: :current_academic_cycle, prefix: true

    def deadline_date
      current_academic_cycle.itt_census_end_date.strftime(Date::DATE_FORMATS[:govuk])
    end

  private

    attr_reader :current_academic_cycle, :provider, :sign_off_period

    def census_period?
      sign_off_period == :census_period
    end
  end
end
