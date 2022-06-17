# frozen_string_literal: true

module Exports
  class FundingTraineeSummaryData
    VULNERABLE_CHARACTERS = %w[= + - @].freeze

    def initialize(trainee_summary, organisation_name)
      @organisation_name = organisation_name
      @trainee_summary = trainee_summary
      @data = format_rows(trainee_summary)
    end

    def csv
      header_row ||= data.first&.keys

      CSV.generate(headers: true) do |rows|
        rows << header_row

        data.map(&:values).each do |value|
          rows << value.map { |v| sanitise(v) }
        end
      end
    end

    def filename
      "#{@organisation_name.gsub(' ', '-')}-trainee-summary-#{@trainee_summary.academic_year}-to-#{@trainee_summary.academic_year.to_i + 1}.csv"
    end

  private

    attr_reader :data

    def format_rows(trainee_summary)
      trainee_summary.rows.map do |row|
        trainee_summary_row_amount = row.amounts.first
        next if trainee_summary_row_amount.nil?

        {
          "Funding type" => funding_type_prefix(row) + trainee_summary_row_amount.payment_type,
          "Route" => row.route,
          "Course" => row.subject,
          "Lead school" => row.lead_school_name,
          "Tier" => trainee_summary_row_amount.tier.present? ? "Tier #{trainee_summary_row_amount.tier}" : "Not applicable",
          "Number of trainees" => trainee_summary_row_amount.number_of_trainees,
          "Amount per trainee" => to_pounds(trainee_summary_row_amount.amount_in_pence),
          "Total" => to_pounds(trainee_summary_row_amount.number_of_trainees * trainee_summary_row_amount.amount_in_pence),
        }
      end.compact
    end

    def sanitise(value)
      return value unless value.is_a?(String)

      value.start_with?(*VULNERABLE_CHARACTERS) ? value.prepend("'") : value
    end

    def to_pounds(value_in_pence)
      ActionController::Base.helpers.number_to_currency(value_in_pence.to_d / 100, unit: "£")
    end

    def funding_type_prefix(row)
      early_years_routes = ["Early years (assessment only)", "Early years (postgrad)", "Early years (salaried)", "Early years (undergrad)"]
      if early_years_routes.include?(row.route)
        "EYITT "
      else
        "ITT "
      end
    end
  end
end
