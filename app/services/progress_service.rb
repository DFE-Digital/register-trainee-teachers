# frozen_string_literal: true

class ProgressService
  class << self
    def call(**args)
      new(**args)
    end
  end

  def initialize(validator:, progress_value:)
    @validator = validator
    @marked_as_completed = progress_value
  end

  def status
    return Progress::STATUSES[:review] if review?
    return Progress::STATUSES[:in_progress] if in_progress?
    return Progress::STATUSES[:completed] if completed?

    Progress::STATUSES[:not_started]
  end

  def started?
    @validator.fields.values.flatten.compact.any?
  end

  def in_progress?
    started? && !completed?
  end

  def review?
    in_progress? && is_apply_application?
  end

  def completed?
    @validator.valid? && marked_as_completed
  end

private

  attr_reader :validator, :marked_as_completed

  def is_apply_application?
    validator.respond_to?(:apply_application?) && validator.apply_application?
  end
end
