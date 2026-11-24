# frozen_string_literal: true

module SystemAdmin
  class FundingSchoolsController < ApplicationController
    # Default until the user picks another year (or "all") from the filter.
    # Not Settings.current_recruitment_cycle_year (that's the live year, currently 2026).
    DEFAULT_ACADEMIC_YEAR = 2027

    helper_method :all_years?

    def index
      @academic_cycles = AcademicCycle.order(start_date: :desc)
      @academic_cycle = academic_cycle_from_params unless all_years?

      scope = FundingSchoolDesignation.includes(:school, :academic_cycle).joins(:school)
      scope = scope.where(academic_cycle: @academic_cycle) unless all_years?

      @designations = scope.order("schools.name")
    end

  private

    def all_years?
      params[:academic_year].to_s == "all"
    end

    def academic_cycle_from_params
      year = params[:academic_year].presence&.to_i
      (AcademicCycle.for_year(year) if year) || AcademicCycle.for_year(DEFAULT_ACADEMIC_YEAR)
    end
  end
end
