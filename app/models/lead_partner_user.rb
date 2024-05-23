# frozen_string_literal: true

# == Schema Information
#
# Table name: lead_partner_users
#
#  id              :bigint           not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  lead_partner_id :bigint           not null
#  user_id         :bigint           not null
#
# Indexes
#
#  index_lead_partner_users_on_lead_partner_id  (lead_partner_id)
#  index_lead_partner_users_on_user_id          (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (lead_partner_id => lead_partners.id)
#  fk_rails_...  (user_id => users.id)
#
class LeadPartnerUser < ApplicationRecord
  belongs_to :lead_partner
  belongs_to :user
end
