# frozen_string_literal: true

class TrainingDetailsForm < TraineeForm
  attr_accessor :provider_trainee_id

  validate :strip_provider_trainee_id
  validates :provider_trainee_id, presence: true,
                                  length: {
                                    maximum: 100,
                                    message: I18n.t("activemodel.errors.models.training_details_form.attributes.provider_trainee_id.max_char_exceeded"),
                                  }
  validate :provider_trainee_id_uniqueness

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
    errors[:provider_trainee_id].include?(duplicate_error_message)
  end

private

  delegate :provider_id, to: :trainee

  def provider_trainee_id_uniqueness
    return if provider_trainee_id.blank?
    return if existing_trainee_with_id.blank?
    return if existing_trainee_with_id.discarded_at.present?
    return if existing_trainee_with_id.inactive?

    errors.add(:provider_trainee_id, duplicate_error_message)
  end

  def existing_trainee_with_id
    return @existing_trainee_with_id if defined?(@existing_trainee_with_id)

    @existing_trainee_with_id = Trainee.where.not(id: trainee.id)
      .where(provider_id:)
      .where("UPPER(provider_trainee_id) = ?", provider_trainee_id.upcase).first
  end

  def duplicate_error_message
    I18n.t("activemodel.errors.models.training_details_form.attributes.provider_trainee_id.uniqueness")
  end

  def strip_provider_trainee_id
    self.provider_trainee_id = provider_trainee_id.to_s.strip
  end

  def compute_fields
    trainee.attributes.symbolize_keys.slice(:provider_trainee_id).merge(new_attributes)
  end

  def update_trainee_attributes
    trainee.assign_attributes(provider_trainee_id:)
  end
end
