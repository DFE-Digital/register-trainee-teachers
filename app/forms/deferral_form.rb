# frozen_string_literal: true

class DeferralForm
  include ActiveModel::Model
  include ActiveModel::AttributeAssignment
  include ActiveModel::Validations::Callbacks

  attr_accessor :trainee, :day, :month, :year, :defer_date_string

  delegate :id, :persisted?, to: :trainee

  validate :defer_date_valid

  after_validation :update_trainee

  def initialize(trainee)
    @trainee = trainee
    super(fields)
  end

  def fields
    {
      defer_date_string: rehydrate_defer_date_string,
      day: trainee.defer_date&.day,
      month: trainee.defer_date&.month,
      year: trainee.defer_date&.year,
    }
  end

  def save
    valid? && trainee.save
  end

  def defer_date
    date_conversion[defer_date_string]
  end

private

  def rehydrate_defer_date_string
    return unless trainee.defer_date

    case trainee.defer_date
    when Time.zone.today
      "today"
    when Time.zone.yesterday
      "yesterday"
    else
      "other"
    end
  end

  def update_trainee
    trainee.assign_attributes({ defer_date: defer_date }) if errors.empty?
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

  def defer_date_valid
    if defer_date_string == "other" && [day, month, year].all?(&:blank?)
      errors.add(:defer_date, :blank)
    elsif !defer_date.is_a?(Date)
      errors.add(:defer_date, :invalid)
    end
  end
end
