# frozen_string_literal: true

class DeferralForm < MultiDateForm
  validate :date_valid, if: :requires_start_date?

  def itt_start_date
    return if itt_not_yet_started?

    @itt_start_date ||= ::TraineeStartStatusForm.new(trainee).commencement_date
  end

  delegate :itt_not_yet_started?, to: :trainee

private

  def assign_attributes_to_trainee
    trainee.commencement_date = itt_start_date if itt_start_date.is_a?(Date)
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
