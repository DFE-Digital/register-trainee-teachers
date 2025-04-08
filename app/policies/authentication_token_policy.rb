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
      return scope.none unless user.provider?

      scope.where(provider_id: user.organisation.id)
    end
  end

  attr_reader :user

  def initialize(user, _record)
    @user = user
  end

  def index?
    user.provider?
  end

  def new?
    user.provider?
  end

  def create?
    user.provider?
  end

  def show?
    user.organisation?
  end

  def update?
    user.organisation?
  end
end
