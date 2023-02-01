# frozen_string_literal: true

# == Schema Information
#
# Table name: dttp_accounts
#
#  id               :bigint           not null, primary key
#  name             :string
#  response         :jsonb
#  ukprn            :string
#  urn              :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  accreditation_id :string
#  dttp_id          :uuid
#
# Indexes
#
#  index_dttp_accounts_on_accreditation_id  (accreditation_id)
#  index_dttp_accounts_on_dttp_id           (dttp_id) UNIQUE
#  index_dttp_accounts_on_ukprn             (ukprn)
#  index_dttp_accounts_on_urn               (urn)
#
module Dttp
  class Account < ApplicationRecord
    self.table_name = "dttp_accounts"
  end
end
