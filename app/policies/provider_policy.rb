# frozen_string_literal: true

class ProviderPolicy
  attr_reader :user

  def initialize(user, provider)
    @user = user
    @provider = provider
  end

  def show?
    user.system_admin?
  end

  alias_method :create?, :show?
  alias_method :new?, :show?
  alias_method :index?, :show?
  alias_method :edit?, :show?
  alias_method :update?, :show?
end
