# frozen_string_literal: true

module Funding
  class PayablePaymentSchedulesImporter
    include ServicePattern
    include HasAmountsInPence

    MONTH_ORDER = [8, 9, 10, 11, 12, 1, 2, 3, 4, 5, 6, 7].freeze

    def initialize(attributes:, first_predicted_month_index: nil)
      @attributes = attributes
      @first_predicted_month_index = first_predicted_month_index
    end

    def call
      missing_payable_ids = []

      attributes.each do |id, row_attributes|
        payable = payable(id)

        if payable.nil?
          missing_payable_ids << id
        else
          schedule = payable.funding_payment_schedules.create

          row_attributes.each do |row_hash|
            row = schedule.rows.create(description: row_hash["Description"])
            Date::MONTHNAMES.compact.each do |month_name|
              month_index = Date::MONTHNAMES.index(month_name)
              row.amounts.create(
                month: month_index,
                year: year_for_month(row_hash["Academic year"], month_index),
                amount_in_pence: in_pence(row_hash[month_name]),
                predicted: predicted?(month_index),
              )
            end
          end
        end
      end

      missing_payable_ids
    end

    def payable(_id)
      raise(NotImplementedException("implement a payable method"))
    end

  private

    attr_reader :attributes, :first_predicted_month_index

    def year_for_month(year_string, month_index)
      years = year_string.split("/")
      year_string = [1, 2, 3, 4, 5, 6, 7].include?(month_index) ? "20#{years[1]}" : years[0]
      year_string.to_i
    end

    def predicted?(month_index)
      return false if first_predicted_month_index.nil?

      MONTH_ORDER.index(month_index) > MONTH_ORDER.index(first_predicted_month_index.to_i)
    end
  end
end
