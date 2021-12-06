# frozen_string_literal: true

class TrainingDetailsForm < TraineeForm
  attr_accessor :trainee_id

  validate :strip_trainee_id
  validates :trainee_id, presence: true,
                         length: {
                           maximum: 100,
                           message: I18n.t("activemodel.errors.models.training_details_form.attributes.trainee_id.max_char_exceeded"),
                         }
  validate :trainee_id_uniqueness

  after_validation :update_trainee_attributes, if: -> { errors.empty? }

  def save
    valid? && trainee.save
  end

  def existing_short_name
    existing_trainee_with_id.short_name || "another trainee"
  end

  def existing_created
    date = existing_trainee_with_id.created_at
    if date.today?
      "today"
    elsif date.yesterday?
      "yesterday"
    else
      date.strftime("%-d %B %Y")
    end
  end

  def duplicate_error?
    errors[:trainee_id].include?(duplicate_error_message)
  end

private

  delegate :provider_id, to: :trainee

  def trainee_id_uniqueness
    return if trainee_id.blank?
    return unless existing_trainee_with_id

    errors.add(:trainee_id, duplicate_error_message)
  end

  def existing_trainee_with_id
    @existing_trainee_with_id ||= Trainee.where.not(id: trainee.id)
      .where(provider_id: provider_id)
      .where("UPPER(trainee_id) = ?", trainee_id.upcase).first
  end

  def duplicate_error_message
    I18n.t("activemodel.errors.models.training_details_form.attributes.trainee_id.uniqueness")
  end

  def strip_trainee_id
    self.trainee_id = trainee_id.to_s.strip
  end

  def compute_fields
    trainee.attributes.symbolize_keys.slice(:trainee_id).merge(new_attributes)
  end

  def update_trainee_attributes
    trainee.assign_attributes(trainee_id: trainee_id)
  end
end
