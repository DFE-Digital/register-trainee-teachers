# frozen_string_literal: true

module BulkUpdate
  class TraineeUploadPolicy
    class Scope
      attr_reader :user, :scope

      def initialize(user, scope)
        @user  = user
        @scope = scope
      end

      def resolve
        scope.where(provider: user.organisation)
      end
    end

    attr_reader :user, :trainee_upload

    def initialize(user, trainee_upload)
      @user           = user
      @trainee_upload = trainee_upload
    end

    def new?
      user.hei_provider?
    end

    def create?
      new? && !trainee_upload.cancelled?
    end

    alias_method :show?, :create?
  end
end
