# frozen_string_literal: true

# == Schema Information
#
# Table name: funding_method_subjects
#
#  id                    :bigint           not null, primary key
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  allocation_subject_id :bigint
#  funding_method_id     :bigint
#
# Indexes
#
#  index_funding_method_subjects_on_allocation_subject_id  (allocation_subject_id)
#  index_funding_method_subjects_on_funding_method_id      (funding_method_id)
#  index_funding_methods_subjects_on_ids                   (allocation_subject_id,funding_method_id) UNIQUE
#
class FundingMethodSubject < ApplicationRecord
  belongs_to :funding_method
  belongs_to :allocation_subject

  validates :allocation_subject, uniqueness: { scope: :funding_method_id }
end
