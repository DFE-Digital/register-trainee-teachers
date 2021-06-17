# frozen_string_literal: true

class Bursary < ApplicationRecord
  has_many :bursary_subjects, inverse_of: :bursary, dependent: :destroy
  has_many :allocation_subjects, through: :bursary_subjects, inverse_of: :bursaries

  validates :training_route, presence: true, inclusion: { in: TRAINING_ROUTE_ENUMS.values }
  validates :amount, presence: true
end
