# frozen_string_literal: true

class DeferralForm < MultiDateForm
  attr_accessor :defer_reason

  MAX_DEFER_REASON_LENGTH = 500

  validate :date_valid, if: :requires_start_date?
  validates :defer_reason, length: { maximum: MAX_DEFER_REASON_LENGTH }

  def itt_start_date
    return if itt_not_yet_started?

    @itt_start_date ||= ::TraineeStartStatusForm.new(trainee).trainee_start_date
  end

  delegate :itt_not_yet_started?, to: :trainee

private

  def additional_fields
    { defer_reason: trainee.defer_reason }
  end

  def assign_attributes_to_trainee
    trainee.trainee_start_date = itt_start_date if itt_start_date.is_a?(Date)
    trainee.state = :deferred
    trainee.defer_reason = defer_reason
    trainee[date_field] = date
  end

  def requires_start_date?
    return false if trainee.starts_course_in_the_future?

    !trainee.itt_not_yet_started?
  end

  def date_field
    @date_field ||= :defer_date
  end

  def form_store_key
    :deferral
  end

  def clear_stash
    [
      TraineeStartStatusForm,
      StartDateVerificationForm,
    ].each do |klass|
      klass.new(trainee).clear_stash
    end

    super
  end
end
