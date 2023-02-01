# frozen_string_literal: true

# == Schema Information
#
# Table name: funding_trainee_summaries
#
#  id            :bigint           not null, primary key
#  academic_year :string
#  payable_type  :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  payable_id    :integer
#
# Indexes
#
#  index_funding_trainee_summaries_on_payable_id_and_payable_type  (payable_id,payable_type)
#
module Funding
  class TraineeSummary < ApplicationRecord
    self.table_name = "funding_trainee_summaries"

    belongs_to :payable, polymorphic: true
    has_many :rows,
             class_name: "Funding::TraineeSummaryRow",
             foreign_key: :funding_trainee_summary_id,
             dependent: :destroy,
             inverse_of: :trainee_summary
  end
end
