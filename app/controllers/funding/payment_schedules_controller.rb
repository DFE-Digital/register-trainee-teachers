# frozen_string_literal: true

module Funding
  class PaymentSchedulesController < ApplicationController
    def show
      @payment_schedule_view = PaymentScheduleView.new(payment_schedule: payment_schedule)
      @navigation_view = NavigationView.new(organisation: organisation)

      @start_year = current_academic_cycle.start_year
      @end_year = current_academic_cycle.end_year
    end

  private

    def organisation
      @organisation ||=  current_user.organisation
    end

    def payment_schedule
      @payment_schedule ||= organisation&.funding_payment_schedules&.order(:created_at)&.last
    end

    def current_academic_cycle
      @current_academic_cycle ||= AcademicCycle.current
    end
  end
end
