# frozen_string_literal: true

class TrainingDetailsForm < TraineeForm
  attr_accessor :trainee_id

  validates :trainee_id, presence: true,
                         length: {
                           maximum: 100,
                           message: I18n.t("activemodel.errors.models.training_details_form.attributes.trainee_id.max_char_exceeded"),
                         }

  after_validation :update_trainee_attributes, if: -> { errors.empty? }

  def save
    valid? && trainee.save
  end

private

  def compute_fields
    trainee.attributes.symbolize_keys.slice(:trainee_id).merge(new_attributes)
  end

  def update_trainee_attributes
    trainee.assign_attributes(trainee_id: trainee_id)
  end
end
