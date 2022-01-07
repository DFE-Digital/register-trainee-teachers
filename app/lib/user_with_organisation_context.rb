# frozen_string_literal: true

class UserWithOrganisationContext < SimpleDelegator
  attr_reader :user

  def initialize(user:, session:)
    __setobj__(user)
    @user = user
    @session = session
  end

  class << self
    def primary_key
      "id"
    end
  end

  def is_a?(value)
    value == User
  end

  def class_name
    "User"
  end

  def organisation
    # TODO: placeholder behaviour. Should return the lead school or
    # provider set in the session
    user.providers.first
  end

private

  attr_reader :session
end
