# frozen_string_literal: true

module BulkUpdate
  RecommendationsUploadPolicy = Struct.new(:user, :record) do
    def create?
      user.provider?
    end
  end
end
