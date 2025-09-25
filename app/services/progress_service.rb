# frozen_string_literal: true

class ProgressService
  class << self
    def call(**)
      new(**)
    end
  end

  def initialize(validator:, progress_value:)
    @validator = validator
    @marked_as_completed = progress_value
  end

  def status
    return Progress::STATUSES[:review] if review?
    return Progress::STATUSES[:in_progress_valid] if in_progress_valid?
    return Progress::STATUSES[:in_progress_invalid] if in_progress_invalid?
    return Progress::STATUSES[:completed] if completed?

    Progress::STATUSES[:incomplete]
  end

  def started?
    @validator.fields.values.flatten.compact.any?
  end

  def not_started?
    !started?
  end

  def in_progress_valid?
    started? && valid? && !completed?
  end

  def in_progress_invalid?
    started? && !valid? && !completed?
  end

  def review?
    (in_progress_valid? || in_progress_invalid? || not_started?) && apply_application?
  end

  def completed?
    valid? && marked_as_completed
  end

  def errors
    validator.errors.full_messages
  end

  def valid?
    return @valid if defined?(@valid)

    @valid = @validator.valid?
  end

private

  attr_reader :validator, :marked_as_completed

  def apply_application?
    validator.respond_to?(:apply_application?) && validator.apply_application?
  end
end
