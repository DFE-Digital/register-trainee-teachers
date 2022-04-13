class TraineePaymentSummaryRowAmount < ApplicationRecord
  belongs_to :trainee_payment_summary_row

  enum payment_type: [
    :bursary,
    :scholarship,
    :grant,
  ]
end
