# frozen_string_literal: true

class TraineeStartStatusForm < TraineeForm
  include DatesHelper
  include CommencementDateHelpers

  WITHDRAW = "withdraw"
  DEFER = "defer"
  DELETE = "delete"

  FIELDS = %i[
    commencement_status
    trainee_start_date
    context
    day
    month
    year
  ].freeze

  attr_accessor(*FIELDS)

  validates :commencement_status, presence: true
  validate :trainee_start_date_valid, if: :itt_started_later?

  def save!
    if valid?
      update_trainee_start_date
      Trainees::Update.call(trainee:)
      clear_stash
    else
      false
    end
  end

  def trainee_start_date
    @trainee_start_date ||= begin
      set_on_time_itt_start_date if itt_started_on_time?
      unset_itt_start_date if itt_not_yet_started?

      date_hash = { year:, month:, day: }
      date_args = date_hash.values.map(&:to_i)

      valid_date?(date_args) ? Date.new(*date_args) : InvalidDate.new(date_hash)
    end
  end

  def itt_not_yet_started?
    commencement_status&.to_sym == :itt_not_yet_started
  end

  def itt_started_on_time?
    commencement_status&.to_sym == :itt_started_on_time
  end

  def itt_started_later?
    commencement_status&.to_sym == :itt_started_later
  end

  def next_step_context?
    [WITHDRAW, DEFER, DELETE].include?(context)
  end

  def deleting?
    context == DELETE
  end

  def withdrawing?
    context == WITHDRAW
  end

  def deferring?
    context == DEFER
  end

  def needs_deferral_date?
    itt_start_date_is_after_deferral_date? || deferral_date.blank?
  end

private

  def itt_start_date_is_after_deferral_date?
    deferral_date.is_a?(Date) && trainee_start_date.after?(deferral_date)
  end

  def deferral_date
    @deferral_date ||= ::DeferralForm.new(trainee).date
  end

  def set_on_time_itt_start_date
    self.day = trainee.itt_start_date.day
    self.month = trainee.itt_start_date.month
    self.year = trainee.itt_start_date.year
  end

  def unset_itt_start_date
    self.day = nil
    self.month = nil
    self.year = nil
  end

  def compute_fields
    {
      commencement_status: trainee.commencement_status,
      day: trainee.trainee_start_date&.day,
      month: trainee.trainee_start_date&.month,
      year: trainee.trainee_start_date&.year,
    }.merge(new_attributes.slice(:day, :month, :year, :commencement_status, :context))
  end

  def update_trainee_start_date
    return unless errors.empty?

    trainee.assign_attributes(trainee_start_date: formatted_trainee_start_date, commencement_status: commencement_status)
  end

  def fields_from_store
    store.get(trainee.id, :trainee_start_status).presence || {}
  end

  def formatted_trainee_start_date
    trainee_start_date.is_a?(Date) ? trainee_start_date : nil
  end
end
