# frozen_string_literal: true

module BulkUpdate
  RecommendationsUploadPolicy = Struct.new(:user, :recommendations_upload) do
    def create?
      user.provider?
    end
  end
end
