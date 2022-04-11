class PaymentProfileRow < ApplicationRecord
  belongs_to :payment_profile
  has_many :amounts, class_name: "PaymentProfileRowAmount", dependent: :destroy
end
