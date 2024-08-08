# frozen_string_literal: true

module SystemAdmin
  module Funding
    class TraineeSummariesController < ::Funding::BaseFundingController
      before_action :redirect_to_trainee_summary_path, unless: -> { academic_year.present? }, only: [:show]

      helper_method :back_path

      def show
        respond_to do |format|
          format.html do
            @trainee_summary_view = ::Funding::TraineeSummaryView.new(trainee_summary:)
            @navigation_view = ::Funding::NavigationView.new(organisation: organisation, system_admin: true)

            @start_year = selected_academic_cycle.start_year
            @end_year = selected_academic_cycle.end_year

            render("funding/trainee_summaries/show")
          end
          format.csv do
            send_data(data_export.csv, filename: data_export.filename, disposition: :attachment)
          end
        end
      end

    private

      def redirect_to_trainee_summary_path
        provider_funding_trainee_summary_path(provider_id: organisation.id, academic_year: selected_academic_cycle.start_year)
      end

      def organisation
        @organisation ||= Provider.find(params[:provider_id]) if params[:provider_id].present?
      end

      def data_export
        @data_export ||= Exports::FundingTraineeSummaryData.new(trainee_summary, organisation.name)
      end

      def back_path
        provider_funding_path
      end
    end
  end
end
