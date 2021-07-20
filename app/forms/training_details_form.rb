# frozen_string_literal: true

class TrainingDetailsForm < TraineeForm
  include TrainingDetailsHelper

  COMMENCEMENT_DATE_RADIO_OPTION_COURSE = "course"
  COMMENCEMENT_DATE_RADIO_OPTION_MANUAL = "manual"

  attr_accessor :trainee_id, :day, :month, :year, :commencement_date_radio_option

  delegate :course_start_date, to: :trainee

  validates :commencement_date_radio_option, inclusion: { in: [COMMENCEMENT_DATE_RADIO_OPTION_COURSE, COMMENCEMENT_DATE_RADIO_OPTION_MANUAL] }, if: :course_start_date
  validate :commencement_date_valid
  validates :trainee_id, presence: true,
                         length: {
                           maximum: 100,
                           message: I18n.t("activemodel.errors.models.training_details_form.attributes.trainee_id.max_char_exceeded"),
                         }

  after_validation :update_trainee_attributes, if: -> { errors.empty? }

  def save
    valid? && trainee.save
  end

  def commencement_date
    if commencement_date_radio_option == COMMENCEMENT_DATE_RADIO_OPTION_COURSE
      course_start_date
    else
      date_hash = { year: year, month: month, day: day }
      date_args = date_hash.values.map(&:to_i)
      valid_date?(date_args) ? Date.new(*date_args) : OpenStruct.new(date_hash)
    end
  end

private

  def compute_fields
    {
      trainee_id: trainee.trainee_id.presence,
      day: trainee.commencement_date&.day,
      month: trainee.commencement_date&.month,
      year: trainee.commencement_date&.year,
      commencement_date_radio_option: compute_commencement_date_radio_option,
    }.merge(new_attributes.slice(:trainee_id, :day, :month, :year, :commencement_date_radio_option))
  end

  def compute_commencement_date_radio_option
    return unless trainee.commencement_date

    course_start_date == trainee.commencement_date ? COMMENCEMENT_DATE_RADIO_OPTION_COURSE : COMMENCEMENT_DATE_RADIO_OPTION_MANUAL
  end

  def update_trainee_attributes
    trainee.assign_attributes(trainee_id: trainee_id, commencement_date: commencement_date)
  end

  def commencement_date_valid
    return if course_start_date && commencement_date_radio_option != COMMENCEMENT_DATE_RADIO_OPTION_MANUAL

    if [day, month, year].all?(&:blank?)
      errors.add(:commencement_date, :blank)
    elsif !commencement_date.is_a?(Date)
      errors.add(:commencement_date, :invalid)
    elsif date_before_course_start_date?(commencement_date, trainee.course_start_date)
      errors.add(:commencement_date, :not_before_course_start_date)
    end
  end

  def valid_date?(date_args)
    Date.valid_date?(*date_args) && date_args.all?(&:positive?)
  end
end
