# frozen_string_literal: true

# == Schema Information
#
# Table name: funding_methods
#
#  id                :bigint           not null, primary key
#  amount            :integer          not null
#  funding_type      :integer
#  training_route    :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  academic_cycle_id :bigint
#
# Indexes
#
#  index_funding_methods_on_academic_cycle_id  (academic_cycle_id)
#
# Foreign Keys
#
#  fk_rails_...  (academic_cycle_id => academic_cycles.id)
#
class FundingMethod < ApplicationRecord
  belongs_to :academic_cycle

  has_many :funding_method_subjects, inverse_of: :funding_method, dependent: :destroy
  has_many :allocation_subjects, through: :funding_method_subjects, inverse_of: :funding_methods

  validates :training_route, presence: true, inclusion: { in: ReferenceData::TRAINING_ROUTES.names }
  validates :amount, presence: true

  enum :funding_type, FUNDING_TYPES
end
