# frozen_string_literal: true

# == Schema Information
#
# Table name: new_partner_users
#
#  id          :bigint           not null, primary key
#  description :string
#  email       :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class NewPartnerUser < ApplicationRecord
end
