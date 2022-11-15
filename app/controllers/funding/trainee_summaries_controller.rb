# frozen_string_literal: true

module Funding
  class TraineeSummariesController < BaseFundingController
    def show
      respond_to do |format|
        format.html do
          @trainee_summary_view = TraineeSummaryView.new(trainee_summary: trainee_summary)
          @navigation_view = ::Funding::NavigationView.new(organisation: organisation)

          current_academic_cycle = AcademicCycle.current
          @start_year = current_academic_cycle.start_year
          @end_year = current_academic_cycle.end_year
        end
        format.csv do
          data_export = Exports::FundingTraineeSummaryData.new(trainee_summary, organisation.name)
          send_data(
            data_export.csv,
            filename: data_export.filename,
            disposition: :attachment,
          )
        end
      end
    end

  private

    def organisation
      @organisation ||= current_user.organisation
    end
  end
end
