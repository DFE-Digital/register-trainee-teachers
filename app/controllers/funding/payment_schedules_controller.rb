# frozen_string_literal: true

module Funding
  class PaymentSchedulesController < ApplicationController
    def show
      payment_schedule = current_user.organisation&.funding_payment_schedules&.order(:created_at)&.last
      @payment_schedule_view = PaymentScheduleView.new(payment_schedule: payment_schedule)
      current_academic_cycle = AcademicCycle.current
      @start_year = current_academic_cycle.start_year
      @end_year = current_academic_cycle.end_year
    end
  end
end
