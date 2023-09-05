# frozen_string_literal: true

module Funding
  class PaymentSchedulesController < BaseFundingController
    before_action :redirect, only: [:show]

    def show
      respond_to do |format|
        format.html do
          @payment_schedule_view = PaymentScheduleView.new(payment_schedule:)
          @navigation_view = NavigationView.new(organisation:)
          @start_year = selected_academic_cycle.start_year
          @end_year = selected_academic_cycle.end_year
        end
        format.csv do
          send_data(
            data_export.to_csv,
            filename: data_export.filename,
            disposition: :attachment,
          )
        end
      end
    end

  private

    def redirect
      return if academic_year.present?

      redirect_to(funding_payment_schedule_path(selected_academic_cycle.start_year))
    end

    def data_export
      @data_export ||= Exports::FundingScheduleData.new(payment_schedule:)
    end

    def organisation
      @organisation ||= current_user.organisation
    end
  end
end
