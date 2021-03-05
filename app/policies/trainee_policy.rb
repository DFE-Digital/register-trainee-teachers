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
    allowed_user?
  end

  def withdraw?
    allowed_user? && (defer? || trainee.deferred?)
  end

  def defer?
    allowed_user? && (trainee.submitted_for_trn? || trainee.trn_received?)
  end

  def reinstate?
    allowed_user? && trainee.deferred?
  end

  alias_method :create?, :show?
  alias_method :update?, :show?
  alias_method :edit?, :show?
  alias_method :new?, :show?
  alias_method :destroy?, :show?
  alias_method :confirm?, :show?
  alias_method :recommended?, :show?

private

  def allowed_user?
    user&.system_admin? || user&.provider == trainee.provider
  end
end
