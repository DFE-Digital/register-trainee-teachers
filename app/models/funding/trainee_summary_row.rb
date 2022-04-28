# frozen_string_literal: true

module Funding
  class TraineeSummaryRow < ApplicationRecord
    self.table_name = "funding_trainee_summary_rows"

    belongs_to :trainee_summary,
               class_name: "Funding::TraineeSummary",
               foreign_key: :funding_trainee_summary_id,
               inverse_of: :rows

    has_many :amounts,
             class_name: "Funding::TraineeSummaryRowAmount",
             foreign_key: :funding_trainee_summary_row_id,
             dependent: :destroy,
             inverse_of: :row
  end
end
