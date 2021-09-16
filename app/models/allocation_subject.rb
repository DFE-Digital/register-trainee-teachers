# frozen_string_literal: true

class AllocationSubject < ApplicationRecord
  has_many :subject_specialisms, inverse_of: :allocation_subject
  has_many :funding_method_subjects, inverse_of: :allocation_subject
  has_many :funding_methods, through: :funding_method_subjects, inverse_of: :allocation_subjects
end
