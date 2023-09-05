# frozen_string_literal: true

class FundingController < ApplicationController
  helper_method :trainee_summary_academic_years, :payment_schedule_academic_years

  def show; end

private

  def trainee_summary_academic_years
    current_user.organisation.funding_trainee_summaries.pluck(:academic_year).map do |year|
      year = year.split("/").first.to_i

      {
        label: "#{year} to #{year + 1}",
        url: funding_trainee_summary_path(year),
      }
    end
  end

  def payment_schedule_academic_years
    current_user
      .organisation
      .funding_payment_schedules
      .joins(rows: :amounts)
      .pluck(Arel.sql("DISTINCT funding_payment_schedule_row_amounts.year")).map do |year|
        {
          label: "#{year} to #{year + 1}",
          url: funding_payment_schedule_path(year),
        }
      end
  end
end
