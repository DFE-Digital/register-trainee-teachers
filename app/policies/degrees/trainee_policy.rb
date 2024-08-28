# frozen_string_literal: true

class Degrees::TraineePolicy
  attr_reader :user, :trainee, :training_route_manager

  def initialize(user, trainee)
    @user                   = user
    @trainee                = trainee
    @training_route_manager = TrainingRouteManager.new(trainee)
  end

  def new?
    (user.system_admin? || user.accredited_provider?) && !user_is_read_only?
  end

  def create?
    (user.system_admin? || (user_in_provider_context? && user.accredited_provider?)) && !user_is_read_only?
  end

private

  def user_is_read_only?
    user&.read_only
  end

  def user_in_provider_context?
    user&.organisation == trainee.provider
  end
end
