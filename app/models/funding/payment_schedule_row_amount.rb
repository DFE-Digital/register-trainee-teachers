# frozen_string_literal: true

module Funding
  class PaymentScheduleRowAmount < ApplicationRecord
    self.table_name = "funding_payment_schedule_row_amounts"

    belongs_to :funding_payment_schedule_row
  end
end
