# frozen_string_literal: true

class ValidationErrorPolicy
  attr_reader :user

  def initialize(user, provider)
    @user = user
    @provider = provider
  end

  def index?
    user.system_admin?
  end
end
