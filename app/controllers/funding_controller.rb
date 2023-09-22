# frozen_string_literal: true

class FundingController < ApplicationController
  helper_method :academic_years

  def show; end

private

  def academic_years
    combined = trainee_summary_academic_years.merge(payment_schedule_academic_years)
    combined.sort_by { |label, _| label }.reverse.to_h
  end

  def trainee_summary_academic_years
    years = organisation&.funding_trainee_summaries&.pluck(:academic_year)
    return {} if years.blank?

    years.each_with_object({}) do |year, hash|
      year_int = year.split("/").first.to_i
      hash["#{year_int} to #{year_int + 1}"] = funding_trainee_summary_path(year_int)
    end
  end

  def payment_schedule_academic_years
    years = organisation&.funding_payment_schedules&.joins(rows: :amounts)&.pluck(Arel.sql("DISTINCT funding_payment_schedule_row_amounts.year"))
    return {} if years.blank?

    years.each_with_object({}) do |year, hash|
      hash["#{year} to #{year + 1}"] = funding_payment_schedule_path(year)
    end
  end

  def organisation
    current_user.organisation
  end
end
