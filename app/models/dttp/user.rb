# frozen_string_literal: true

module Dttp
  class User < ApplicationRecord
    self.table_name = "dttp_users"

    def name
      "#{first_name} #{last_name}"
    end

    def self.not_registered_with_provider(provider_dttp_id, provider_user_dttp_ids)
      where(provider_dttp_id: provider_dttp_id).where.not(dttp_id: provider_user_dttp_ids)
    end
  end
end
