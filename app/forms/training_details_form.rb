# frozen_string_literal: true

class TrainingDetailsForm < TraineeForm
  attr_accessor :trainee_id, :day, :month, :year

  validates :trainee_id, presence: true,
                         length: {
                           maximum: 100,
                           message: I18n.t("activemodel.errors.models.training_details_form.attributes.trainee_id.max_char_exceeded"),
                         }

  validate :commencement_date_valid

  after_validation :update_trainee_attributes, if: -> { errors.empty? }

  def save
    valid? && trainee.save
  end

  def commencement_date
    date_hash = { year: year, month: month, day: day }
    date_args = date_hash.values.map(&:to_i)

    valid_date?(date_args) ? Date.new(*date_args) : OpenStruct.new(date_hash)
  end

private

  def compute_fields
    {
      trainee_id: trainee.trainee_id.presence,
      day: trainee.commencement_date&.day,
      month: trainee.commencement_date&.month,
      year: trainee.commencement_date&.year,
    }.merge(new_attributes.slice(:trainee_id, :day, :month, :year))
  end

  def update_trainee_attributes
    trainee.assign_attributes(trainee_id: trainee_id, commencement_date: commencement_date)
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
