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
      if user.training_partner?
        training_partner_scope
      else
        provider_scope
      end
    end

    def provider_scope
      scope.where(provider_id: user.organisation.id).kept
    end

    def training_partner_scope
      scope.where(training_partner_id: user.organisation.id).kept
    end
  end

  attr_reader :user, :trainee, :training_route_manager

  delegate :requires_training_partner?,
           :requires_employing_school?,
           :requires_itt_start_date?,
           to: :training_route_manager

  def initialize(user, trainee)
    @user = user
    @trainee = trainee
    @training_route_manager = TrainingRouteManager.new(trainee)
  end

  def show?
    read?
  end

  def new?
    user.accredited_provider? && !user_is_read_only?
  end

  def create?
    user_in_provider_context? && user.accredited_provider? && !user_is_read_only?
  end

  def update?
    write?
  end

  def withdraw?
    defer? || user_is_system_admin?
  end

  def undo_withdraw?
    write? && trainee.withdrawn?
  end

  def defer?
    allow_actions? && (trainee.submitted_for_trn? || trainee.trn_received? || trainee.deferred?)
  end

  def reinstate?
    allow_actions? && trainee.deferred?
  end

  def recommended?
    read? && trainee.recommended_for_award?
  end

  def recommend_for_award?
    allow_actions? && trainee.trn_received?
  end

  def export?
    user_is_system_admin? || user.provider?
  end

  def hide_progress_tag?
    user.training_partner?
  end

  def allow_actions?
    return false if user_is_read_only?

    user_is_system_admin? || (user_in_provider_context? && trainee.awaiting_action?)
  end

  def destroy_with_reason?
    user_is_system_admin? && !trainee.recommended_for_award? && !trainee.awarded?
  end

  alias_method :index?, :show?
  alias_method :edit?, :update?
  alias_method :destroy?, :update?
  alias_method :confirm?, :update?
  alias_method :delete?, :destroy?

  def write_placements?
    return false if user_is_read_only?

    user_is_system_admin? || user_in_provider_context?
  end

private

  def read?
    user_is_system_admin? ||
      user_in_provider_context? ||
      user_in_training_partner_context?
  end

  def write?
    return false if user_is_read_only?

    user_is_system_admin? || (
      user_in_provider_context? && trainee.awaiting_action? && (
        !trainee.hesa_record? || trainee.hesa_editable?
      )
    )
  end

  def user_in_provider_context?
    user&.organisation == trainee.provider
  end

  def user_is_read_only?
    user&.read_only
  end

  def user_in_training_partner_context?
    return false if trainee.training_partner.nil?

    user&.organisation == trainee.training_partner
  end

  def user_is_system_admin?
    user&.system_admin?
  end
end
