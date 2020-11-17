# frozen_string_literal: true

class ProgressService
  class << self
    def call(**args)
      new(**args)
    end
  end

  def initialize(validator:, progress_value:)
    @validator = validator
    @progress_value = progress_value
  end

  def status
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

  def completed?
    @validator.valid? && progress_value
  end

private

  attr_reader :validator, :progress_value
end
