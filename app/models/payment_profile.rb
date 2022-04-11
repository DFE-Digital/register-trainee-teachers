class PaymentProfile < ApplicationRecord
  belongs_to :payable
  has_many :rows, class_name: "PaymentProfileRow", dependent: :destroy
end
