# frozen_string_literal: true

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

    scope :active, -> { where(status_code: STATUS_CODES[:active]) }
  end
end
