# frozen_string_literal: true

class StartDateVerificationForm
  include ActiveModel::Model

  WITHDRAW = "withdraw"
  DELETE = "delete"

  attr_accessor :trainee_has_started_course, :context

  validates :trainee_has_started_course, presence: true, inclusion: { in: %w[yes no] }

  def already_started?
    trainee_has_started_course == "yes"
  end

  def withdrawing?
    context == WITHDRAW
  end
end
