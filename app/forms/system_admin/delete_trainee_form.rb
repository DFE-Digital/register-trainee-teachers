# frozen_string_literal: true

module SystemAdmin
  class DeleteTraineeForm < TraineeForm
    ANOTHER_REASON = "Another reason"
    DELETE_REASONS = [
      "Duplicate record",
      "Record added in error",
      "Trainee already has QTS",
      "Trainee did not start training",
    ].freeze

    FIELDS = %i[
      delete_reason
      additional_delete_reason
      ticket
    ].freeze

    attr_accessor(*FIELDS)

    validate :delete_reason_valid
    validate :additional_delete_reason_valid

    def save!
      return false unless valid?

      trainee.update(discarded_at: Time.current, audit_comment: audit_comment)

      clear_stash
    end

    def delete_reason_or_other
      for_another_reason? ? additional_delete_reason : delete_reason
    end

  private

    def compute_fields
      new_attributes
    end

    def audit_comment
      [delete_reason_or_other, ticket].compact.join("\n")
    end

    def for_another_reason?
      delete_reason == ANOTHER_REASON
    end

    def delete_reason_valid
      errors.add(:delete_reason, :invalid) if delete_reason.blank?
    end

    def additional_delete_reason_valid
      errors.add(:additional_delete_reason, :blank) if for_another_reason? && additional_delete_reason.blank?
    end

    def form_store_key
      :delete_trainee
    end
  end
end
