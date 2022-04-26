# frozen_string_literal: true

module Funding
  class PaymentScheduleRow < ApplicationRecord
    self.table_name = "funding_payment_schedule_rows"

    belongs_to :funding_payment_schedule
    has_many :amounts, class_name: "Funding::PaymentScheduleRowAmount", dependent: :destroy
  end
end
