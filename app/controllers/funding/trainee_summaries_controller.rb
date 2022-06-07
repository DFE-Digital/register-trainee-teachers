# frozen_string_literal: true

module Funding
  class TraineeSummariesController < ApplicationController
    def show
      @trainee_summary_view = TraineeSummaryView.new(trainee_summary: trainee_summary)
      @navigation_view = NavigationView.new(organisation: organisation)

      @start_year = current_academic_cycle.start_year
      @end_year = current_academic_cycle.end_year
    end

  private

    def organisation
      @organisation ||= current_user.organisation
    end

    def trainee_summary
      @trainee_summary ||= organisation&.funding_trainee_summaries&.order(:created_at)&.last
    end

    def current_academic_cycle
      @current_academic_cycle ||= AcademicCycle.current
    end
  end
end
