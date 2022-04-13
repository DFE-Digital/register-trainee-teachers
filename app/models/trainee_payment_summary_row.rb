class TraineePaymentSummaryRow < ApplicationRecord
  belongs_to :trainee_payment_summary
  has_many :amounts, class_name: "TraineePaymentSummaryRowAmount", dependent: :destroy
end
