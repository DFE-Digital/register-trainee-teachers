# frozen_string_literal: true

class ProgrammeDetailForm
  include ActiveModel::Model
  include ActiveModel::AttributeAssignment
  include ActiveModel::Validations::Callbacks

  attr_accessor :trainee, :subject, :main_age_range,
                :additional_age_range, :start_day, :start_month, :start_year,
                :end_day, :end_month, :end_year

  delegate :id, :persisted?, to: :trainee

  before_validation :sanitise_programme_dates

  validates :subject, presence: true
  validate :age_range_valid
  validate :programme_start_date_valid
  validate :programme_end_date_valid

  after_validation :update_trainee

  MAX_END_YEARS = 4

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
    new_date({ year: start_year, month: start_month, day: start_day })
  end

  def programme_end_date
    new_date({ year: end_year, month: end_month, day: end_day })
  end

  def sanitise_programme_dates
    programme_dates = %w[start_day
                         start_month
                         start_year
                         end_day
                         end_month
                         end_year]

    return if programme_dates.any?(&:nil?)

    programme_dates.each do |date_attribute|
      date = "#{date_attribute}="
      sanitised_date = public_send(date_attribute).to_s.gsub(/\s+/, "")
      public_send(date, sanitised_date)
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

  def new_date(date_hash)
    date_args = date_hash.values.map(&:to_i)
    Date.valid_date?(*date_args) ? Date.new(*date_args) : OpenStruct.new(date_hash)
  end

  def age_range
    return additional_age_range if main_age_range.to_sym == :other

    main_age_range
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
    elsif start_year.to_i > next_year
      errors.add(:programme_start_date, :future)
    elsif !programme_start_date.is_a?(Date)
      errors.add(:programme_start_date, :invalid)
    elsif programme_start_date < 10.years.ago
      errors.add(:programme_start_date, :too_old)
    end
  end

  def programme_end_date_valid
    if [end_day, end_month, end_year].all?(&:blank?)
      errors.add(:programme_end_date, :blank)
    elsif end_year.to_i > max_years
      errors.add(:programme_end_date, :future)
    elsif !programme_end_date.is_a?(Date)
      errors.add(:programme_end_date, :invalid)
    elsif programme_end_date < 10.years.ago
      errors.add(:programme_end_date, :too_old)
    end

    additional_validation = errors.attribute_names.none? do |attribute_name|
      %i[programme_start_date programme_end_date].include?(attribute_name)
    end

    if additional_validation && programme_start_date >= programme_end_date
      errors.add(:programme_end_date, :before_or_same_as_start_date)
    end
  end

  def next_year
    Time.zone.now.year.next
  end

  def max_years
    next_year + MAX_END_YEARS
  end
end
