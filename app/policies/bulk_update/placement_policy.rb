# frozen_string_literal: true

module BulkUpdate
  PlacementPolicy = Struct.new(:user, :record) do
    def new?
      user.provider?
    end

    alias_method :create?, :new?
  end
end
