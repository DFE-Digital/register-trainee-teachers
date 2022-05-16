# frozen_string_literal: true

module Funding
  class TraineeSummariesController < ApplicationController
    def show
      trainee_summary = current_user.organisation&.funding_trainee_summaries&.order(:created_at)&.last
      @trainee_summary_view = TraineeSummaryView.new(trainee_summary: trainee_summary)
      current_academic_cycle = AcademicCycle.current
      @start_year = current_academic_cycle.start_year
      @end_year = current_academic_cycle.end_year
    end
  end
end
