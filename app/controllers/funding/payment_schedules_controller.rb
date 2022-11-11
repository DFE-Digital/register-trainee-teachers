# frozen_string_literal: true

module Funding
  class PaymentSchedulesController < BaseFundingController
    def show
      respond_to do |format|
        format.html do
          @payment_schedule_view = PaymentScheduleView.new(payment_schedule: payment_schedule)
          @navigation_view = NavigationView.new(organisation: organisation)
          @start_year = current_academic_cycle.start_year
          @end_year = current_academic_cycle.end_year
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

    def data_export
      @data_export ||= Exports::FundingScheduleData.new(payment_schedule: payment_schedule)
    end

    def organisation
      @organisation ||= current_user.organisation
    end
  end
end
