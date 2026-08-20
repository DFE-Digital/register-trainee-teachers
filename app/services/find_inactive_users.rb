# frozen_string_literal: true

class FindInactiveUsers
  include ServicePattern

  attr_reader :cutoff

  def initialize(cutoff: Settings.discard_inactive_users.inactive_after_days.days.ago)
    @cutoff = cutoff
  end

  def call
    not_signed_in_since_cutoff.or(never_signed_in_and_created_before_cutoff)
  end

private

  def active_users
    User.kept.where.not(system_admin: true)
  end

  def not_signed_in_since_cutoff
    active_users.where(last_signed_in_at: ...cutoff)
  end

  def never_signed_in_and_created_before_cutoff
    active_users.where(last_signed_in_at: nil, created_at: ...cutoff)
  end
end
