# frozen_string_literal: true

class SchoolPolicy
  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope.all
    end
  end

  attr_reader :user

  def initialize(user, school)
    @user = user
    @school = school
  end

  def show?
    user.system_admin?
  end

  alias_method :create?, :show?
  alias_method :new?, :show?
  alias_method :index?, :show?
  alias_method :edit?, :show?
  alias_method :update?, :show?
  alias_method :destroy?, :show?
  alias_method :delete?, :show?
end
