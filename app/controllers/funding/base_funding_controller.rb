# frozen_string_literal: true

module Funding
  class BaseFundingController < ApplicationController
    def current_academic_cycle
      @current_academic_cycle ||= AcademicCycle.current
    end

    def academic_year_string
      @academic_year_string ||= "#{current_academic_cycle.start_date.year}/#{current_academic_cycle.end_date.year % 100}"
    end

    def payment_schedule
      return if payment_schedules.blank?

      @payment_schedule ||= payment_schedules.order(:created_at).includes(rows: :amounts).select { |schedule| schedule.start_year == current_academic_cycle.start_year }.last
    end

    def payment_schedules
      organisation.funding_payment_schedules
    end

    def trainee_summary
      return if trainee_summaries.blank?

      @trainee_summary ||= trainee_summaries.order(:created_at).last
    end

    def trainee_summaries
      organisation.funding_trainee_summaries.where(academic_year: academic_year_string)
    end
  end
end
