# frozen_string_literal: true

class TrainingDetailsForm
  include ActiveModel::Model
  include ActiveModel::AttributeAssignment
  include ActiveModel::Validations::Callbacks

  attr_accessor :trainee, :trainee_id, :day, :month, :year, :validate_commencement_date, :validate_trainee_id

  delegate :id, :persisted?, to: :trainee

  validates :trainee_id, presence: true,
                         length: {
                           maximum: 100,
                           message: I18n.t("activemodel.errors.models.training_details_form.attributes.trainee_id.max_char_exceeded"),
                         },
                         if: -> { validate_trainee_id }

  validate :commencement_date_valid, if: -> { validate_commencement_date }

  after_validation :update_trainee_id, if: -> { validate_trainee_id && errors.empty? }
  after_validation :update_trainee_commencement_date, if: -> { validate_commencement_date && errors.empty? }

  def initialize(trainee, validate_trainee_id: true, validate_commencement_date: true)
    @trainee = trainee
    @validate_trainee_id = validate_trainee_id
    @validate_commencement_date = validate_commencement_date
    super(fields)
  end

  def fields
    {
      trainee_id: trainee.trainee_id.presence,
      day: trainee.commencement_date&.day,
      month: trainee.commencement_date&.month,
      year: trainee.commencement_date&.year,
    }
  end

  def save
    valid? && trainee.save
  end

  def commencement_date
    date_hash = { year: year, month: month, day: day }
    date_args = date_hash.values.map(&:to_i)

    valid_date?(date_args) ? Date.new(*date_args) : OpenStruct.new(date_hash)
  end

private

  def update_trainee_id
    trainee.assign_attributes(trainee_id: trainee_id)
  end

  def update_trainee_commencement_date
    trainee.assign_attributes(commencement_date: commencement_date)
  end

  def commencement_date_valid
    if [day, month, year].all?(&:blank?)
      errors.add(:commencement_date, :blank)
    elsif !commencement_date.is_a?(Date)
      errors.add(:commencement_date, :invalid)
    end
  end

  def valid_date?(date_args)
    Date.valid_date?(*date_args) && date_args.all?(&:positive?)
  end
end
