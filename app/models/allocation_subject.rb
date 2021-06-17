# frozen_string_literal: true

class AllocationSubject < ApplicationRecord
  has_many :subject_specialisms, inverse_of: :allocation_subject
end
