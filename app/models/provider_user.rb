# frozen_string_literal: true

# == Schema Information
#
# Table name: provider_users
#
#  id          :bigint           not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  provider_id :bigint           not null
#  user_id     :bigint           not null
#
# Indexes
#
#  index_provider_users_on_provider_id              (provider_id)
#  index_provider_users_on_provider_id_and_user_id  (provider_id,user_id) UNIQUE
#  index_provider_users_on_user_id                  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (provider_id => providers.id)
#  fk_rails_...  (user_id => users.id)
#
class ProviderUser < ApplicationRecord
  belongs_to :provider
  belongs_to :user

  validates :user, uniqueness: { scope: :provider_id }

  audited associated_with: :provider

  scope :with_active_hei_providers, -> { where(provider: Provider.with_active_hei) }
end
