# frozen_string_literal: true

module SystemAdmin
  module Funding
    class PaymentSchedulesController < ::Funding::BaseFundingController
      before_action :redirect_to_schedule_path, unless: -> { academic_year.present? }, only: [:show]

      helper_method :back_path

      def show
        respond_to do |format|
          format.html do
            @payment_schedule_view = ::Funding::PaymentScheduleView.new(payment_schedule:)
            @navigation_view = ::Funding::NavigationView.new(organisation: organisation, system_admin: true)

            @start_year = selected_academic_cycle.start_year
            @end_year = selected_academic_cycle.end_year

            render("funding/payment_schedules/show")
          end
          format.csv do
            send_data(data_export.to_csv, filename: data_export.filename, disposition: :attachment)
          end
        end
      end

    private

      def redirect_to_schedule_path
        case organisation
        when Provider
          redirect_to(provider_funding_payment_schedule_path(provider_id: organisation.id, academic_year: selected_academic_cycle.start_year))
        when School
          redirect_to(lead_school_funding_payment_schedule_path(lead_school_id: organisation.id, academic_year: selected_academic_cycle.start_year))
        end
      end

      def organisation
        @organisation ||= params[:provider_id].present? ? Provider.find(params[:provider_id]) : School.find(params[:lead_school_id])
      end

      def data_export
        @data_export ||= Exports::FundingScheduleData.new(payment_schedule:)
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
