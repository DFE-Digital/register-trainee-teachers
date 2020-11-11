class ProgressService
  attr_reader :status, :trainee

  class << self
    def call(**args)
      new(**args).call
    end
  end

  def initialize(validator:, progress_value:)
    @validator = validator
    @progress_value = progress_value
  end

  def call
    return Progress::STATUSES[:in_progress] if in_progress?
    return Progress::STATUSES[:completed] if completed?

    Progress::STATUSES[:not_started]
  end

private

  attr_reader :validator, :progress_value

  def started?
    @validator.fields.values.flatten.compact.any?
  end

  def in_progress?
    started? && !completed?
  end

  def completed?
    @validator.valid? && progress_value
  end
end
