class TraineePaymentSummary < ApplicationRecord
  belongs_to :payable
  has_many :rows, class_name: "TraineePaymentSummaryRow", dependent: :destroy
end
