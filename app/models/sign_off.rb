# == Schema Information
#
# Table name: sign_offs
#
#  id                :bigint           not null, primary key
#  sign_off_type     :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  academic_cycle_id :bigint           not null
#  provider_id       :bigint           not null
#  user_id           :bigint           not null
#
# Indexes
#
#  index_sign_offs_on_academic_cycle_id  (academic_cycle_id)
#  index_sign_offs_on_provider_id        (provider_id)
#  index_sign_offs_on_user_id            (user_id)
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
  enum sign_off_type: TYPES.map { |type| [type, type] }.to_h

  scope :current_academic_cycle, -> do
    return none unless AcademicCycle.current.present?
    joins(:academic_cycle).where(academic_cycles: { id: AcademicCycle.current.id })
  end
end
