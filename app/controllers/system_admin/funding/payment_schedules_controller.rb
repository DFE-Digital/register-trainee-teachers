# frozen_string_literal: true

module SystemAdmin
  module Funding
    class PaymentSchedulesController < ApplicationController
      def show
        @payment_schedule_view = ::Funding::PaymentScheduleView.new(payment_schedule: payment_schedule)
        @navigation_view = ::Funding::NavigationView.new(organisation: organisation, system_admin: true)

        @start_year = current_academic_cycle.start_year
        @end_year = current_academic_cycle.end_year

        render("funding/payment_schedules/show")
      end

    private

      def organisation
        @organisation ||= params[:provider_id].present? ? Provider.find(params[:provider_id]) : School.find(params[:lead_school_id])
      end

      def payment_schedule
        @payment_schedule ||= organisation.funding_payment_schedules&.order(:created_at)&.last
      end

      def current_academic_cycle
        @current_academic_cycle ||= AcademicCycle.current
      end
    end
  end
end
