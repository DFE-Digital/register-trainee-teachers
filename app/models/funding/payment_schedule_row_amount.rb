# frozen_string_literal: true

# == Schema Information
#
# Table name: funding_payment_schedule_row_amounts
#
#  id                              :bigint           not null, primary key
#  amount_in_pence                 :integer
#  month                           :integer
#  predicted                       :boolean
#  year                            :integer
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  funding_payment_schedule_row_id :integer
#
# Indexes
#
#  index_payment_schedule_row_amounts_on_payment_schedule_row_id  (funding_payment_schedule_row_id)
#
module Funding
  class PaymentScheduleRowAmount < ApplicationRecord
    self.table_name = "funding_payment_schedule_row_amounts"

    belongs_to :row,
               class_name: "Funding::PaymentScheduleRow",
               foreign_key: :funding_payment_schedule_row_id,
               inverse_of: :amounts
  end
end
