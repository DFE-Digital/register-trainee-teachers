# frozen_string_literal: true

module SystemAdmin
  class FundingController < ApplicationController
    helper_method :academic_years

    def show
      render("funding/show")
    end

  private

    def academic_years
      combined = trainee_summary_academic_years.merge(payment_schedule_academic_years)
      combined.sort_by { |label, _| label }.reverse.to_h
    end

    def trainee_summary_academic_years
      years = organisation.funding_trainee_summaries.pluck(:academic_year)
      return {} if years.blank?

      years.each_with_object({}) do |year, hash|
        year = year.split("/").first.to_i
        hash["#{year} to #{year + 1}"] = funding_path(year, "trainee_summary")
      end
    end

    def payment_schedule_academic_years
      years = organisation.funding_payment_schedules.joins(rows: :amounts)&.pluck(Arel.sql("DISTINCT funding_payment_schedule_row_amounts.year"))
      return {} if years.blank?

      years.each_with_object({}) do |year, hash|
        hash["#{year} to #{year + 1}"] = funding_path(year, "payment_schedule")
      end
    end

    def funding_path(year, funding_type)
      send("provider_funding_#{funding_type}_path", provider_id: organisation.id, academic_year: year)
    end

    def organisation
      Provider.find(params[:provider_id]) if params[:provider_id].present?
    end
  end
end
