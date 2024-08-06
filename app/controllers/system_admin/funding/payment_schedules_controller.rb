# frozen_string_literal: true

module SystemAdmin
  module Funding
    class PaymentSchedulesController < ::Funding::BaseFundingController
      before_action :redirect_to_schedule_path, unless: -> { academic_year.present? }, only: [:show]

      helper_method :back_path

      attr_reader :start_year, :end_year

      def show
        @start_year = selected_academic_cycle.start_year
        @end_year = selected_academic_cycle.end_year

        respond_to do |format|
          format.html do
            @payment_schedule_view = ::Funding::PaymentScheduleView.new(payment_schedule:)
            @navigation_view = ::Funding::NavigationView.new(organisation: organisation, system_admin: true)

            render("funding/payment_schedules/show")
          end
          format.csv do
            send_data(data_export.to_csv, filename: data_export.filename, disposition: :attachment)
          end
        end
      end

    private

      def redirect_to_schedule_path
        redirect_to(provider_funding_payment_schedule_path(provider_id: organisation.id, academic_year: selected_academic_cycle.start_year))
      end

      def organisation
        @organisation ||= Provider.find(params[:provider_id]) if params[:provider_id].present?
      end

      def data_export
        @data_export ||= Exports::FundingScheduleData.new(
          payment_schedule:,
          start_year:,
          end_year:,
        )
      end

      def back_path
        case organisation
        when Provider
          provider_funding_path
        when School
          lead_school_funding_path
        end
      end
    end
  end
end
