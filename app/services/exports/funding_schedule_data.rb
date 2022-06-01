# frozen_string_literal: true

module Exports
  class FundingScheduleData
    def initialize(payment_schedule:)
      @payment_schedule = payment_schedule
    end

    def csv
      header_row ||= data.first&.keys

      CSV.generate(headers: true) do |rows|
        rows << header_row

        data.each do |row|
          rows << row.values
        end
      end
    end

    def data
      month_order = Funding::PayablePaymentSchedulesImporter::MONTH_ORDER

      data = month_order.map.with_index do |month, month_index|
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
      "#{Time.zone.now.strftime('%Y-%m-%d_%H-%M_%S')}_Funding-schedule_exported_records.csv"
    end

  private

    attr_reader :payment_schedule

    def amount_for(row, month)
      row.amounts.find { |amount| amount.month == month }
    end

    def label_for(month)
      year = month > 7 ? AcademicCycle.current.start_year : AcademicCycle.current.end_year
      Date.new(year, month).to_s(:govuk_approx)
    end
  end
end
