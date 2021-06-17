# frozen_string_literal: true

class BursarySubject < ApplicationRecord
  belongs_to :bursary
  belongs_to :allocation_subject

  validates :bursary, presence: true
  validates :allocation_subject, presence: true, uniqueness: { scope: :bursary_id }
end
