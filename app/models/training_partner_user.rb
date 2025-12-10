# frozen_string_literal: true

# == Schema Information
#
# Table name: training_partner_users
#
#  id                  :bigint           not null, primary key
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  training_partner_id :bigint           not null
#  user_id             :bigint           not null
#
# Indexes
#
#  index_training_partner_users_on_training_partner_id  (training_partner_id)
#  index_training_partner_users_on_user_id              (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (training_partner_id => training_partners.id)
#  fk_rails_...  (user_id => users.id)
#
class TrainingPartnerUser < ApplicationRecord
  belongs_to :training_partner
  belongs_to :user
end
