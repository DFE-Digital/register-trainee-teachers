# frozen_string_literal: true

class LeadPartnerPolicy
  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      if user.system_admin?
        scope.all
      else
        scope.none
      end
    end
  end

  attr_reader :user

  def initialize(user, lead_partner)
    @user = user
    @lead_partner = lead_partner
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
