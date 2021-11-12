# frozen_string_literal: true

class StartDateVerificationForm < TraineeForm
  FIELDS = %i[
    context
    trainee_has_started_course
  ].freeze

  WITHDRAW = "withdraw"
  DEFER = "defer"
  DELETE = "delete"

  attr_accessor(*FIELDS)

  validates :trainee_has_started_course, presence: true, inclusion: { in: %w[yes no] }

  def save!
    if valid?
      update_trainee_commencement_status
      trainee.save!
      clear_stash
    else
      false
    end
  end

  def already_started?
    trainee_has_started_course == "yes"
  end

  def withdrawing?
    context == WITHDRAW
  end

  def deferring?
    context == DEFER
  end

private

  def update_trainee_commencement_status
    trainee.assign_attributes(commencement_status: commencement_status)
  end

  def commencement_status
    trainee_has_started_course == "no" ? :itt_not_yet_started : nil
  end

  def compute_fields
    new_attributes.slice(*FIELDS)
  end
end
