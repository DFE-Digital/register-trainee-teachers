# frozen_string_literal: true

class SubjectSpecialism < ApplicationRecord
  belongs_to :allocation_subject, inverse_of: :subject_specialisms
end
