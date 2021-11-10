# frozen_string_literal: true

class StartDateVerificationForm
  include ActiveModel::Model

  attr_accessor :trainee_has_started_course

  validates :trainee_has_started_course, presence: true, inclusion: { in: %w[yes no] }

  def initialize(params = {})
    @trainee_has_started_course = params[:trainee_has_started_course]
  end

  def already_started?
    trainee_has_started_course == "yes"
  end
end
