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

  attr_reader :user, :trainee, :training_route_manager

  delegate :requires_schools?,
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
    user.provider?
  end

  def create?
    user_in_provider_context?
  end

  def update?
    write?
  end

  def withdraw?
    write? && (defer? || trainee.deferred?)
  end

  def defer?
    write? && (trainee.submitted_for_trn? || trainee.trn_received?)
  end

  def reinstate?
    write? && trainee.deferred?
  end

  def recommended?
    read? && trainee.recommended_for_award?
  end

  def recommend_for_award?
    write? && trainee.trn_received?
  end

  def export?
    user_is_system_admin? || user.provider?
  end

  def hide_progress_tag?
    user.lead_school? || hesa_record?
  end

  alias_method :index?, :show?

  alias_method :edit?, :update?
  alias_method :destroy?, :update?
  alias_method :confirm?, :update?

private

  def read?
    user_is_system_admin? || user_in_provider_context? || user_in_lead_school_context?
  end

  def write?
    user_is_system_admin? || (!hesa_record? && user_in_provider_context? && trainee.awaiting_action?)
  end

  def hesa_record?
    trainee.hesa_id.present?
  end

  def user_in_provider_context?
    user&.organisation == trainee.provider
  end

  def user_in_lead_school_context?
    return false if trainee.lead_school.nil?

    user&.organisation == trainee.lead_school
  end

  def user_is_system_admin?
    user&.system_admin?
  end
end
