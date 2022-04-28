# frozen_string_literal: true

module Funding
  class PaymentScheduleRowAmount < ApplicationRecord
    self.table_name = "funding_payment_schedule_row_amounts"

    belongs_to :row,
               class_name: "Funding::PaymentScheduleRow",
               foreign_key: :funding_payment_schedule_row_id,
               inverse_of: :amounts
  end
end
