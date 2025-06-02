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
      return scope.none unless user.hei_provider?

      scope.where(provider_id: user.organisation.id)
    end
  end

  attr_reader :user
  attr_reader :token

  def initialize(user, token)
    @user = user
    @token = token
  end

  def index?
    user.hei_provider?
  end

  def new?
    user.hei_provider?
  end

  def create?
    user.hei_provider?
  end

  def show?
    user.hei_provider? && token.can_revoke?
  end

  def update?
    user.hei_provider? && token.can_revoke?
  end
end
