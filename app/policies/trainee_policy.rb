# frozen_string_literal: true

class TraineePolicy
  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope.where(provider_id: user.provider_id)
    end
  end
end
