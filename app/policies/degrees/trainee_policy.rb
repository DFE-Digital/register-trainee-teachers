# frozen_string_literal: true

class Degrees::TraineePolicy < TraineePolicy
  def new?
    (user.system_admin? || user.accredited_provider?) && !user_is_read_only?
  end

  def create?
    (user.system_admin? || (user_in_provider_context? && user.accredited_provider?)) && !user_is_read_only?
  end
end
