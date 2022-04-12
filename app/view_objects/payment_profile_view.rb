# frozen_string_literal: true

class PaymentProfileView
  include ActionView::Helpers

  class MonthBreakdown
    attr_reader :title, :rows, :total_amount, :total_running_total

    def initialize(title, row_data, total_amount, total_running_total)
      @title = title
      @rows = row_data
      @total_amount = total_amount
      @total_running_total = total_running_total
    end
  end

  def initialize(payment_profile:)
    @payment_profile = payment_profile
  end

  def actual_payments
    payment_data_for(actual_months)
  end

  def predicted_payments
    payment_data_for(predicted_months)
  end

  def month_breakdowns
    all_rows = payment_profile.rows
    all_months.map do |month_index|
      MonthBreakdown.new(
        month_string(month_index),
        month_breakdown(month_index),
        format_pounds(total_amount_for(all_rows, month_index)),
        format_pounds(total_running_total_for(all_rows, month_index)),
      )
    end
  end

  private

  attr_reader :payment_profile

  def month_total(month_index)
    payment_profile.rows.sum do |row|
      amount_for(row, month_index).amount_in_pence
    end
  end

  def month_breakdown(month_index)
    payment_profile.rows.map do | row |
      amount_for_month = amount_for(row, month_index)
      amount = amount_for_month.amount_in_pence
      { description: row.description, amount: format_pounds(amount), running_total: format_pounds(running_total_for(row, month_index)) }
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
    return "–" if value_in_pence == 0
    number_to_currency(value_in_pence.to_d/100, unit: "£")
  end

  def actual_months
    payment_profile.rows.first.amounts.map { |amount| amount.month unless amount.predicted? }.compact
  end

  def predicted_months
    payment_profile.rows.first.amounts.map { |amount| amount.month if amount.predicted? }.compact
  end

  def all_months
    payment_profile.rows.first.amounts.map(&:month)
  end

  def month_string(month_index)
    "#{Date::MONTHNAMES[month_index]} #{year_for(month_index)}"
  end

  def year_for(month_index)
    amount_for(payment_profile.rows.first, month_index).year
  end

  def amount_for(row, month_index)
    row.amounts.find { |amount| amount.month == month_index }
  end

  def payment_data_for(months)
    running_total = 0
    months.map do |month_index|
      total = month_total(month_index)
      running_total = running_total + total
      { month: month_string(month_index), total: format_pounds(total), running_total: format_pounds(running_total) }
    end
  end

  def running_total_for(row, at_month_index)
    running_total = 0
    all_months.each do |month_index|
      running_total = running_total + amount_for(row, month_index).amount_in_pence
      break if month_index == at_month_index
    end

    running_total
  end
end
