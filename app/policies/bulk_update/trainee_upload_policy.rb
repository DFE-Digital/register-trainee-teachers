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

    def show?
      trainee_upload.submitted? || trainee_upload.succeeded?
    end

    def create?
      trainee_upload.validated?
    end
  end
end
