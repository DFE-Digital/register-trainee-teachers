# frozen_string_literal: true

module Funding
  class TraineeSummary < ApplicationRecord
    self.table_name = "funding_trainee_summaries"

    belongs_to :payable, polymorphic: true
    has_many :rows, class_name: "Funding::TraineePaymentSummaryRow", dependent: :destroy
  end
end
