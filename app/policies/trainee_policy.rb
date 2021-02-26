# frozen_string_literal: true

class TraineePolicy
  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      user.system_admin? ? scope.all : scope.where(provider_id: user.provider_id)
    end
  end

  attr_reader :user, :trainee

  def initialize(user, trainee)
    @user = user
    @trainee = trainee
  end

  def show?
    user && (user.system_admin? || user.provider_id == trainee.provider_id)
  end

  def confirm?
    user && (user.system_admin? || user.provider_id == trainee.provider_id)
  end

  def recommended?
    user && (user.system_admin? || user.provider_id == trainee.provider_id)
  end

  def withdraw?
    defer? || trainee.deferred?
  end

  def defer?
    trainee.submitted_for_trn? || trainee.trn_received?
  end

  def destroy?
    user && (user.system_admin? || user.provider_id == trainee.provider_id)
  end

  alias_method :create?, :show?
  alias_method :update?, :show?
  alias_method :edit?, :show?
  alias_method :new?, :show?
end
