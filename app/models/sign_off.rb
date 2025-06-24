# frozen_string_literal: true

# == Schema Information
#
# Table name: sign_offs
#
#  id                :bigint           not null, primary key
#  sign_off_type     :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  academic_cycle_id :bigint           not null
#  provider_id       :bigint           not null
#  user_id           :bigint           not null
#
# Indexes
#
#  idx_on_provider_id_academic_cycle_id_sign_off_type_fc3b6ade67  (provider_id,academic_cycle_id,sign_off_type) UNIQUE
#  index_sign_offs_on_academic_cycle_id                           (academic_cycle_id)
#  index_sign_offs_on_provider_id                                 (provider_id)
#  index_sign_offs_on_user_id                                     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (academic_cycle_id => academic_cycles.id)
#  fk_rails_...  (provider_id => providers.id)
#  fk_rails_...  (user_id => users.id)
#
class SignOff < ApplicationRecord
  belongs_to :provider
  belongs_to :academic_cycle
  belongs_to :user

  TYPES = %w[performance_profile census].freeze
  enum(:sign_off_type, TYPES.to_h { |type| [type, type] })

  scope :previous_academic_cycle, lambda {
    return none if AcademicCycle.previous.blank?

    joins(:academic_cycle).where(academic_cycles: { id: AcademicCycle.previous.id })
  }

  scope :current_academic_cycle, lambda {
    return none if AcademicCycle.previous.blank?

    joins(:academic_cycle).where(academic_cycles: { id: AcademicCycle.current.id })
  }
end
