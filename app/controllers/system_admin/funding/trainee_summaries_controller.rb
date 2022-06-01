# frozen_string_literal: true

module SystemAdmin
  module Funding
    class TraineeSummariesController < ApplicationController
      def show
        @trainee_summary_view = ::Funding::TraineeSummaryView.new(trainee_summary: trainee_summary)
        @navigation_view = ::Funding::NavigationView.new(organisation: organisation, system_admin: true)

        @start_year = current_academic_cycle.start_year
        @end_year = current_academic_cycle.end_year

        render 'funding/trainee_summaries/show'
      end

    private

      def organisation
        @organisation ||= authorize(Provider.find(params[:provider_id]))
      end

      def trainee_summary
        @trainee_summary ||= organisation&.funding_trainee_summaries&.order(:created_at)&.last
      end

      def current_academic_cycle
        @current_academic_cycle ||= AcademicCycle.current
      end
    end
  end
end
