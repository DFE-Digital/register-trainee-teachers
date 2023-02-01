# frozen_string_literal: true

# == Schema Information
#
# Table name: funding_payment_schedule_rows
#
#  id                          :bigint           not null, primary key
#  description                 :string
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  funding_payment_schedule_id :integer
#
# Indexes
#
#  index_payment_schedule_rows_on_funding_payment_schedule_id  (funding_payment_schedule_id)
#
module Funding
  class PaymentScheduleRow < ApplicationRecord
    self.table_name = "funding_payment_schedule_rows"

    belongs_to :payment_schedule,
               class_name: "Funding::PaymentSchedule",
               foreign_key: :funding_payment_schedule_id,
               inverse_of: :rows

    has_many :amounts,
             class_name: "Funding::PaymentScheduleRowAmount",
             foreign_key: :funding_payment_schedule_row_id,
             dependent: :destroy,
             inverse_of: :row
  end
end
