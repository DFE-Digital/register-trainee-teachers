# frozen_string_literal: true

module BulkUpdate
  RecommendationsUploadPolicy = Struct.new(:user, :record) do
    def new?
      user.provider? && !user.read_only
    end

    alias_method :create?, :new?
    alias_method :edit?, :new?
    alias_method :update?, :new?
    alias_method :show?, :new?
    alias_method :confirmation?, :new?
    alias_method :cancel?, :new?
  end
end
