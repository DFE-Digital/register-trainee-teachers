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

  attr_reader :user, :trainee

  def initialize(user, trainee)
    @user = user
    @trainee = trainee
  end

  def show?
    user && user.provider_id == trainee.provider_id
  end

  def confirm?
    user && user.provider_id == trainee.provider_id
  end

  def recommended?
    user && user.provider_id == trainee.provider_id
  end

  alias_method :create?, :show?
  alias_method :update?, :show?
  alias_method :edit?, :show?
  alias_method :new?, :show?
end
