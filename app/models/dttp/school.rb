# frozen_string_literal: true

# == Schema Information
#
# Table name: dttp_schools
#
#  id          :bigint           not null, primary key
#  name        :string
#  status_code :integer
#  urn         :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  dttp_id     :string
#
# Indexes
#
#  index_dttp_schools_on_dttp_id  (dttp_id) UNIQUE
#
module Dttp
  class School < ApplicationRecord
    self.table_name = "dttp_schools"

    STATUS_CODES = {
      active: 1,
      inactive: 2,
      closed: 300000002,
      new: 300000007,
      open_closing: 300000000,
      notification_to_close: 300000005,
      pnp_active: 300000003,
      proposed_to_open: 300000008,
    }.freeze

    ACTIVE_STATUS_CODES = [STATUS_CODES[:active], STATUS_CODES[:new]].freeze

    scope :active, -> { where(status_code: ACTIVE_STATUS_CODES) }
  end
end
