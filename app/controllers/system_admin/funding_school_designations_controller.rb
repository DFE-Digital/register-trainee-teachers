# frozen_string_literal: true

module SystemAdmin
  class FundingSchoolDesignationsController < ApplicationController
    helper_method :all_years?

    def index
      @academic_cycles = AcademicCycle.order(start_date: :desc)
      @academic_cycle = academic_cycle_from_params unless all_years?

      scope = FundingSchoolDesignation.includes(:school, :academic_cycle).joins(:school)
      scope = scope.where(academic_cycle: @academic_cycle) unless all_years?

      @designations = scope.order("schools.name").page(params[:page] || 1)
    end

  private

    def all_years?
      params[:academic_year].to_s == "all"
    end

    def academic_cycle_from_params
      year = params[:academic_year].presence&.to_i
      (AcademicCycle.for_year(year) if year) || default_academic_cycle
    end

    def default_academic_cycle
      current = AcademicCycle.current
      return current if current && FundingSchoolDesignation.exists?(academic_cycle: current)

      AcademicCycle.next || current
    end
  end
end
