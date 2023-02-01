# frozen_string_literal: true

# == Schema Information
#
# Table name: funding_trainee_summary_row_amounts
#
#  id                             :bigint           not null, primary key
#  amount_in_pence                :integer
#  number_of_trainees             :integer
#  payment_type                   :integer
#  tier                           :integer
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  funding_trainee_summary_row_id :integer
#
# Indexes
#
#  index_trainee_summary_row_amounts_on_trainee_summary_row_id  (funding_trainee_summary_row_id)
#
module Funding
  class TraineeSummaryRowAmount < ApplicationRecord
    self.table_name = "funding_trainee_summary_row_amounts"

    belongs_to :row,
               class_name: "Funding::TraineeSummaryRow",
               foreign_key: :funding_trainee_summary_row_id,
               inverse_of: :amounts

    enum payment_type: { bursary: 0, scholarship: 1, grant: 2 }

    def tiered_bursary?
      bursary? && tier.present?
    end

    def untiered_bursary?
      bursary? && tier.blank?
    end
  end
end
