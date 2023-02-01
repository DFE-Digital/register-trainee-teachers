# frozen_string_literal: true

# == Schema Information
#
# Table name: allocation_subjects
#
#  id            :bigint           not null, primary key
#  deprecated_on :date
#  name          :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  dttp_id       :string
#
# Indexes
#
#  index_allocation_subjects_on_dttp_id  (dttp_id) UNIQUE
#  index_allocation_subjects_on_name     (name) UNIQUE
#
class AllocationSubject < ApplicationRecord
  has_many :subject_specialisms, inverse_of: :allocation_subject
  has_many :funding_method_subjects, inverse_of: :allocation_subject
  has_many :funding_methods, through: :funding_method_subjects, inverse_of: :allocation_subjects
end
