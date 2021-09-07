# frozen_string_literal: true

class FundingMethodSubject < ApplicationRecord
  belongs_to :funding_method
  belongs_to :allocation_subject

  validates :funding_method, presence: true
  validates :allocation_subject, presence: true, uniqueness: { scope: :funding_method_id }
end
