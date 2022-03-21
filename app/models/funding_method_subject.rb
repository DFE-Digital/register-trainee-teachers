# frozen_string_literal: true

class FundingMethodSubject < ApplicationRecord
  belongs_to :funding_method
  belongs_to :allocation_subject

  validates :allocation_subject, uniqueness: { scope: :funding_method_id }
end
