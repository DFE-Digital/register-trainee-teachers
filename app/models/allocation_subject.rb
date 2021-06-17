# frozen_string_literal: true

class AllocationSubject < ApplicationRecord
  has_many :subject_specialisms, inverse_of: :allocation_subject
  has_many :bursary_subjects, inverse_of: :allocation_subject
  has_many :bursaries, through: :bursary_subjects, inverse_of: :allocation_subjects
end
