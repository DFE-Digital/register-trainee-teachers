# frozen_string_literal: true

class ProgrammeDetailForm
  include ActiveModel::Model
  include ActiveModel::AttributeAssignment
  include ActiveModel::Validations::Callbacks

  attr_accessor :trainee, :subject, :main_age_range,
                :additional_age_range, :start_day, :start_month, :start_year,
                :end_day, :end_month, :end_year

  delegate :id, :persisted?, to: :trainee

  validates :subject, presence: true
  validate :age_range_valid
  validate :programme_start_date_valid
  validate :programme_end_date_valid

  after_validation :update_trainee

  def initialize(trainee)
    @trainee = trainee

    super(fields)
  end

  def fields
    attributes = {
      subject: trainee.subject,
      start_day: trainee.programme_start_date&.day,
      start_month: trainee.programme_start_date&.month,
      start_year: trainee.programme_start_date&.year,
      end_day: trainee.programme_end_date&.day,
      end_month: trainee.programme_end_date&.month,
      end_year: trainee.programme_end_date&.year,
    }

    age_range = Dttp::CodeSets::AgeRanges::MAPPING[trainee.age_range]

    if age_range.present?
      attributes["#{age_range[:option]}_age_range".to_sym] = trainee.age_range
      attributes[:main_age_range] = :other if age_range[:option] == :additional
    end

    attributes
  end

  def programme_start_date
    date_hash = { start_year: start_year, start_month: start_month, start_day: start_day }
    date_args = date_hash.values.map(&:to_i)

    if Date.valid_date?(*date_args)
      Date.new(*date_args)
    else
      Struct.new(*date_hash.keys).new(*date_hash.values)
    end
  end

  def programme_end_date
    date_hash = { end_year: end_year, end_month: end_month, end_day: end_day }
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
        programme_end_date: programme_end_date,
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
    if [start_day, start_month, start_year].all?(&:blank?)
      errors.add(:programme_start_date, :blank)
    elsif !programme_start_date.is_a?(Date)
      errors.add(:programme_start_date, :invalid)
    end
  end

  def programme_end_date_valid
    if [end_day, end_month, end_year].all?(&:blank?)
      errors.add(:programme_end_date, :blank)
    elsif !programme_end_date.is_a?(Date)
      errors.add(:programme_end_date, :invalid)
    end
  end
end
