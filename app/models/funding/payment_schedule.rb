# frozen_string_literal: true

# == Schema Information
#
# Table name: funding_payment_schedules
#
#  id           :bigint           not null, primary key
#  payable_type :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  payable_id   :integer
#
# Indexes
#
#  index_funding_payment_schedules_on_payable_id_and_payable_type  (payable_id,payable_type)
#
module Funding
  class PaymentSchedule < ApplicationRecord
    self.table_name = "funding_payment_schedules"

    belongs_to :payable, polymorphic: true
    has_many :rows,
             class_name: "Funding::PaymentScheduleRow",
             dependent: :destroy,
             foreign_key: :funding_payment_schedule_id,
             inverse_of: :payment_schedule

    def start_year
      return if rows.empty?
      return if rows.first.amounts.empty?

      rows.first.amounts.minimum(:year)
    end

    def end_year
      return if rows.empty?
      return if rows.first.amounts.empty?

      rows.first.amounts.maximum(:year)
    end
  end
end
