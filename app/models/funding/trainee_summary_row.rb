# frozen_string_literal: true

module Funding
  class TraineeSummaryRow < ApplicationRecord
    self.table_name = "funding_trainee_summary_rows"

    belongs_to :trainee_summary
    has_many :amounts, class_name: "Funding::TraineePaymentSummaryRowAmount", dependent: :destroy
  end
end
