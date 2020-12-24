# frozen_string_literal: true

class OutcomeDateForm
  include ActiveModel::Model
  include ActiveModel::AttributeAssignment
  include ActiveModel::Validations::Callbacks

  attr_accessor :trainee, :day, :month, :year, :outcome_date_string

  delegate :id, :persisted?, to: :trainee

  validate :outcome_date_valid

  after_validation :update_trainee

  def initialize(trainee)
    @trainee = trainee
    super(fields)
  end

  def fields
    {
      outcome_date_string: rehydrate_outcome_date_string,
      day: trainee.outcome_date&.day,
      month: trainee.outcome_date&.month,
      year: trainee.outcome_date&.year,
    }
  end

  def save
    valid? && trainee.save
  end

  def outcome_date
    date_conversion[outcome_date_string]
  end

private

  def rehydrate_outcome_date_string
    return unless trainee.outcome_date

    case trainee.outcome_date
    when Time.zone.today
      "today"
    when Time.zone.yesterday
      "yesterday"
    else
      "other"
    end
  end

  def update_trainee
    trainee.assign_attributes({ outcome_date: outcome_date }) if errors.empty?
  end

  def date_conversion
    {
      today: Time.zone.today,
      yesterday: Time.zone.yesterday,
      other: other_date,
    }.with_indifferent_access
  end

  def other_date
    date_hash = { year: year, month: month, day: day }
    date_args = date_hash.values.map(&:to_i)

    Date.valid_date?(*date_args) ? Date.new(*date_args) : OpenStruct.new(date_hash)
  end

  def outcome_date_valid
    if outcome_date_string.nil?
      errors.add(:outcome_date_string, :blank)
    elsif outcome_date_string == "other" && [day, month, year].all?(&:blank?)
      errors.add(:outcome_date, :blank)
    elsif !outcome_date.is_a?(Date)
      errors.add(:outcome_date, :invalid)
    end
  end
end
