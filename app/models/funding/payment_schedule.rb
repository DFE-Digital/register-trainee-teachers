# frozen_string_literal: true

module Funding
  class PaymentSchedule < ApplicationRecord
    self.table_name = "funding_payment_schedules"

    belongs_to :payable, polymorphic: true
    has_many :rows, class_name: "Funding::PaymentScheduleRow", dependent: :destroy
  end
end
