# frozen_string_literal: true

class UserWithOrganisationContext < SimpleDelegator
  attr_reader :user

  def initialize(user:, session:)
    __setobj__(user)
    @user = user
    @session = session
  end

  def organisation
    # TODO: placeholder behaviour. Should return the lead school or
    # provider set in the session
    user.providers.first
  end

private

  attr_reader :session
end
