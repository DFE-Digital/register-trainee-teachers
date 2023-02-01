# frozen_string_literal: true

# == Schema Information
#
# Table name: dttp_users
#
#  id               :bigint           not null, primary key
#  email            :string
#  first_name       :string
#  last_name        :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  dttp_id          :string
#  provider_dttp_id :string
#
# Indexes
#
#  index_dttp_users_on_dttp_id  (dttp_id) UNIQUE
#
module Dttp
  class User < ApplicationRecord
    self.table_name = "dttp_users"
  end
end
