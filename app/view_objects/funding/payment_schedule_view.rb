# frozen_string_literal: true

module Funding
  class PaymentScheduleView
    include ActionView::Helpers

    BLANK_CHARACTER = "–"

    MonthBreakdown = Struct.new(:title, :rows, :total_amount, :total_running_total) do
      def no_payments?
        rows.all? { |row| row[:amount] == BLANK_CHARACTER }
      end
    end

    def initialize(payment_schedule:)
      @payment_schedule = payment_schedule
    end

    def actual_payments
      payment_data_for(actual_months)
    end

    def predicted_payments
      initial_total = actual_months.sum do |month_index|
        month_total(month_index)
      end

      payment_data_for(predicted_months, initial_total: initial_total)
    end

    def payment_breakdown
      payment_rows = payment_schedule.rows
      all_months.map { |month_index|
        MonthBreakdown.new(
          month_name_and_year(month_index),
          sort(month_breakdown(month_index)),
          format_pounds(total_amount_for(payment_rows, month_index)),
          format_pounds(total_running_total_for(payment_rows, month_index)),
        )
      }
    end

    def any?
      payment_schedule&.rows&.any?
    end

    def last_updated_at
      payment_schedule.created_at.strftime("%d %B %Y")
    end

  private

    attr_reader :payment_schedule

    def month_total(month_index)
      payment_schedule.rows.sum do |row|
        amount_for(row, month_index).amount_in_pence
      end
    end

    def month_breakdown(month_index)
      payment_schedule.rows.map do |row|
        amount_for_month = amount_for(row, month_index)
        amount = amount_for_month.amount_in_pence
        {
          description: row.description,
          amount: format_pounds(amount),
          running_total: format_pounds(running_total_for(row, month_index)),
        }
      end
    end

    def total_amount_for(rows, month_index)
      rows.sum do |row|
        amount_for(row, month_index).amount_in_pence
      end
    end

    def total_running_total_for(rows, month_index)
      rows.sum do |row|
        running_total_for(row, month_index)
      end
    end

    def format_pounds(value_in_pence)
      return BLANK_CHARACTER if value_in_pence.zero?

      number_to_currency(value_in_pence.to_d / 100, unit: "£")
    end

    def actual_months
      payment_schedule.rows.flat_map do |row|
        row.amounts.order(:year, :month).filter_map do |amount|
          amount.month unless amount.predicted?
        end
      end.uniq
    end

    def predicted_months
      payment_schedule.rows.flat_map do |row|
        row.amounts.order(:year, :month).filter_map do |amount|
          amount.month if amount.predicted?
        end
      end.uniq
    end

    def all_months
      payment_schedule.rows.first.amounts.order(:year, :month).map(&:month)
    end

    def month_name_and_year(month_index)
      "#{Date::MONTHNAMES[month_index]} #{year_for(month_index)}"
    end

    def year_for(month_index)
      amount_for(payment_schedule.rows.first, month_index).year
    end

    def amount_for(row, month_index)
      row.amounts.find { |amount| amount.month == month_index }
    end

    def payment_data_for(months, initial_total: 0)
      running_total = initial_total

      months.map do |month_index|
        total = month_total(month_index)
        running_total += total
        {
          month: month_name_and_year(month_index),
          total: format_pounds(total),
          running_total: format_pounds(running_total),
        }
      end
    end

    def running_total_for(row, at_month_index)
      running_total = 0

      all_months.each do |month_index|
        running_total += amount_for(row, month_index).amount_in_pence
        break if month_index == at_month_index
      end

      running_total
    end

    def sort(payment_rows)
      payment_rows.sort { |a, b| a[:description] <=> b[:description] }
    end
  end
end
