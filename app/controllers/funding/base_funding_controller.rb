# frozen_string_literal: true

module Funding
  class BaseFundingController < ApplicationController
    helper_method :back_path

    def selected_academic_cycle
      @selected_academic_cycle ||=
        academic_year.blank? ? AcademicCycle.current : AcademicCycle.for_year(academic_year)
    end

    def academic_year_string
      @academic_year_string ||= "#{selected_academic_cycle.start_date.year}/#{selected_academic_cycle.end_date.year % 100}"
    end

    def payment_schedule
      return if payment_schedules.blank?

      @payment_schedule ||= payment_schedules.order(:created_at).includes(rows: :amounts).select { |schedule| schedule.start_year == selected_academic_cycle.start_year }.last
    end

    def payment_schedules
      organisation.funding_payment_schedules
    end

    def trainee_summary
      return if trainee_summaries.blank?

      @trainee_summary ||= trainee_summaries.order(:created_at).last
    end

    def trainee_summaries
      organisation.funding_trainee_summaries.includes(:payable, rows: %i[amounts trainee_summary]).where(academic_year: academic_year_string)
    end

    def academic_year
      params[:academic_year]
    end

    def back_path
      funding_path
    end

    def organisation
      @organisation ||=
        if params[:provider_id].present?
          Provider.find(params[:provider_id])
        elsif params[:lead_school_id].present?
          School.find(params[:lead_school_id])
        else
          LeadPartner.find(params[:lead_partner_id])
        end
    end
  end
end
