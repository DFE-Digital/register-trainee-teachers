# frozen_string_literal: true

module Funding
  class TraineeSummaryRowAmount < ApplicationRecord
    self.table_name = "funding_trainee_summary_row_amounts"

    belongs_to :row,
               class_name: "Funding::TraineeSummaryRow",
               foreign_key: :funding_trainee_summary_row_id,
               inverse_of: :amounts
  end
end
