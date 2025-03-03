# frozen_string_literal: true

class OrganisationSettingsPolicy
  attr_reader :user

  def initialize(user, _record)
    @user = user
  end

  def show?
    user.organisation?
  end
end
