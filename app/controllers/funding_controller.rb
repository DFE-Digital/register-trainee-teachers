# frozen_string_literal: true

class FundingController < ApplicationController
  helper_method :academic_years

  def show; end

private

  def academic_years
    current_user.organisation.funding_trainee_summaries.pluck(:academic_year).map do |year|
      year = year.split("/").first.to_i

      {
        label: "#{year} to #{year + 1}",
        url: funding_trainee_schedule_url(year),
      }
    end
  end
end
