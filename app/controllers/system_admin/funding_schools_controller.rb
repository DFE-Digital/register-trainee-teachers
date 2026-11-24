# frozen_string_literal: true

module SystemAdmin
  class FundingSchoolsController < ApplicationController
    # Temporary: hard-scoped to 2027/28 until an academic year filter is added.
    # Not Settings.current_recruitment_cycle_year (that's the live year, currently 2026).
    ACADEMIC_YEAR = 2027

    def index
      @academic_cycle = AcademicCycle.for_year(ACADEMIC_YEAR)

      @designations = FundingSchoolDesignation
        .includes(:school)
        .joins(:school)
        .where(academic_cycle: @academic_cycle)
        .order("schools.name")
    end
  end
end
