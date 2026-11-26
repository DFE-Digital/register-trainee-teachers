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

  validates :trainee_has_started_course, presence: true, unless: :eytda?
  validates :trainee_has_started_course, presence: { message: :eytda_blank }, if: :eytda?
  validates :trainee_has_started_course, inclusion: { in: %w[yes no] }

  def save!
    if valid?
      update_trainee_commencement_status
      Trainees::Update.call(trainee:)
      clear_stash
    else
      false
    end
  end

  # The EYTDA error says "course" rather than "ITT".
  def eytda?
    RouteTerminology.eytda?(trainee)
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
    attributes = { commencement_status: }

    attributes.merge!(trainee_start_date: nil) if not_yet_started?

    trainee.assign_attributes(attributes)
  end

  def commencement_status
    not_yet_started? ? :itt_not_yet_started : nil
  end

  def not_yet_started?
    trainee_has_started_course == "no"
  end

  def compute_fields
    new_attributes.slice(*FIELDS)
  end
end
