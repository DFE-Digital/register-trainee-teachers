# frozen_string_literal: true

class TraineePolicy
  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      user.system_admin? ? scope.all : user_scope
    end

  private

    attr_reader :user, :scope

    def user_scope
      return lead_school_scope if user.lead_school?

      provider_scope
    end

    def provider_scope
      scope.where(provider_id: user.organisation.id).kept
    end

    def lead_school_scope
      scope.where(lead_school_id: user.organisation.id).kept
    end
  end

  delegate :requires_schools?,
           :requires_employing_school?,
           :requires_itt_start_date?,
           to: :training_router_manager

  def initialize(user, trainee)
    @user = user
    @trainee = trainee
    @training_router_manager = TrainingRouteManager.new(trainee)
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

  def show_recommended?
    allowed_user? && trainee.recommended_for_award?
  end

  def recommend_for_award?
    allowed_user? && trainee.trn_received?
  end

  alias_method :index?, :show?
  alias_method :create?, :show?
  alias_method :update?, :show?
  alias_method :edit?, :show?
  alias_method :new?, :show?
  alias_method :destroy?, :show?
  alias_method :confirm?, :show?
  alias_method :recommended?, :show?

private
  attr_reader :user, :trainee, :training_router_manager

  def allowed_user?
    user&.system_admin? || user&.provider == trainee.provider
  end

end
