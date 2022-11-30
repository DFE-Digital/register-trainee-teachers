# frozen_string_literal: true

module Exports
  class FundingScheduleData
    include ExportsHelper

    def initialize(payment_schedule:)
      @payment_schedule = payment_schedule
    end

    def to_csv
      header_row = sanitize_row(data.first&.keys)

      CSV.generate(headers: true) do |rows|
        rows << header_row

        data.each do |row|
          rows << sanitize_row(formatted_values(row))
        end
      end
    end

    def data
      month_order = Funding::PayablePaymentSchedulesImporter::MONTH_ORDER

      data = month_order.map.with_index do |month, _month_index|
        data_for_month = { "Month" => label_for(month) }

        month_total = 0
        payment_schedule.rows.each do |row|
          amount = amount_for(row, month)&.amount_in_pence || 0
          data_for_month[row.description] = amount
          month_total += amount
        end
        data_for_month["Month total"] = month_total

        data_for_month
      end

      totals = {
        "Month" => "Total",
      }
      data.first.keys.excluding("Month").each do |key|
        totals[key] = data.inject(0) { |total, row| total + row[key] }
      end

      data << totals
    end

    def filename
      "#{organisation_name.downcase.gsub(' ', '-')}-payment_schedule-#{payment_schedule.start_year}-to-#{payment_schedule.end_year}.csv"
    end

  private

    attr_reader :payment_schedule

    def amount_for(row, month)
      row.amounts.find { |amount| amount.month == month }
    end

    def label_for(month)
      year = month > 7 ? AcademicCycle.current.start_year : AcademicCycle.current.end_year
      Date.new(year, month).to_fs(:govuk_approx)
    end

    def formatted_values(row)
      [row.values.first] + row.values[1..].map { |amount_in_pence| format_amount(amount_in_pence) }
    end

    def format_amount(amount_in_pence)
      amount_in_pence.zero? ? "0" : ActionController::Base.helpers.number_to_currency(amount_in_pence.to_d / 100, unit: "£")
    end

    def sanitize_row(row)
      row.map { |value| sanitize(value) }
    end

    def organisation_name
      @payment_schedule.payable.name
    end
  end
end
