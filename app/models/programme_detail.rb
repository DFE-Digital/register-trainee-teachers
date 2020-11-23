# frozen_string_literal: true

class ProgrammeDetail
  include ActiveModel::Model
  include ActiveModel::AttributeAssignment
  include ActiveModel::Validations::Callbacks

  attr_accessor :trainee, :subject, :main_age_range,
                :additional_age_range, :day, :month, :year

  delegate :id, :persisted?, to: :trainee

  validates :subject, presence: true
  validate :age_range_valid
  validate :programme_start_date_valid

  after_validation :update_trainee

  def initialize(trainee)
    @trainee = trainee

    super(fields)
  end

  def fields
    attributes = {
      subject: trainee.subject,
      day: trainee.programme_start_date&.day,
      month: trainee.programme_start_date&.month,
      year: trainee.programme_start_date&.year,
    }

    age_range = AGE_RANGES.find { |a| a[:name] == trainee.age_range }

    if age_range.present?
      attributes["#{age_range[:option]}_age_range".to_sym] = age_range[:name]
      attributes[:main_age_range] = :other if age_range[:option] == :additional
    end

    attributes
  end

  def programme_start_date
    date_hash = { year: year, month: month, day: day }
    date_args = date_hash.values.map(&:to_i)

    if Date.valid_date?(*date_args)
      Date.new(*date_args)
    else
      Struct.new(*date_hash.keys).new(*date_hash.values)
    end
  end

private

  def update_trainee
    if errors.empty?
      trainee.assign_attributes({
        subject: subject,
        age_range: age_range,
        programme_start_date: programme_start_date,
      })
    end
  end

  def age_range
    if main_age_range.to_sym == :other
      additional_age_range
    else
      main_age_range
    end
  end

  def age_range_valid
    if main_age_range.blank?
      errors.add(:main_age_range, :blank)
    elsif main_age_range.to_sym == :other && additional_age_range.blank?
      errors.add(:additional_age_range, :blank)
    end
  end

  def programme_start_date_valid
    if [day, month, year].all?(&:blank?)
      errors.add(:programme_start_date, :blank)
    elsif !programme_start_date.is_a?(Date)
      errors.add(:programme_start_date, :invalid)
    end
  end
end
