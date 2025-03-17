# frozen_string_literal: true

class AuthenticationTokenPolicy
  class Scope
    attr_reader :user
    attr_reader :scope

    def initialize(user, scope)
      @user  = user
      @scope = scope
    end

    def resolve
      scope.where(provider: user.organisation)
    end
  end

  attr_reader :user

  def initialize(user, _record)
    @user = user
  end

  def index?
    user.organisation?
  end
end
