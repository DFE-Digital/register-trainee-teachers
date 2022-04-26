# frozen_string_literal: true

module Funding
  class TraineeSummaryRowAmount < ApplicationRecord
    self.table_name = "funding_trainee_summary_row_amounts"

    belongs_to :trainee_summary_row
  end
end
