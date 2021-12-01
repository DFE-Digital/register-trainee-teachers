# frozen_string_literal: true

class FundingMethod < ApplicationRecord
  belongs_to :academic_cycle

  has_many :funding_method_subjects, inverse_of: :funding_method, dependent: :destroy
  has_many :allocation_subjects, through: :funding_method_subjects, inverse_of: :funding_methods

  validates :training_route, presence: true, inclusion: { in: TRAINING_ROUTE_ENUMS.values }
  validates :amount, presence: true

  enum funding_type: FUNDING_TYPES
end
