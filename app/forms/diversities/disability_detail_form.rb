# frozen_string_literal: true

module Diversities
  class DisabilityDetailForm < TraineeForm
    attr_accessor :disability_ids, :additional_disability

    validate :disabilities_cannot_be_empty, if: -> { disability_disclosure_form.disabled? && disabilities.empty? }

    def initialize(trainee, **kwargs)
      @disability_disclosure_form = DisabilityDisclosureForm.new(trainee)
      super(trainee, **kwargs)
    end

    def save!
      if valid?
        Trainee.transaction do
          trainee.disability_ids = fields[:disability_ids] # This will actually persist the records
          other_trainee_disability&.update!(additional_disability: fields[:additional_disability])
        end

        clear_stash

        true
      else
        false
      end
    end

    def disabilities
      Disability.where(id: disability_ids)
    end

  private

    attr_reader :disability_disclosure_form

    def compute_fields
      {
        disability_ids: trainee.disability_ids,
        additional_disability: other_trainee_disability&.additional_disability,
      }.merge(new_attributes)
    end

    def new_attributes
      if disability_disclosure_form.disabled?
        fields_from_store.merge(params).symbolize_keys.tap do |f|
          f[:disability_ids] = f[:disability_ids].reject(&:blank?).map(&:to_i) if f[:disability_ids]
        end
      else
        { disability_ids: [], additional_disability: nil }
      end
    end

    def disabilities_cannot_be_empty
      errors.add(:disability_ids, :empty_disabilities)
    end

    def other_trainee_disability
      @other_trainee_disability ||= trainee.trainee_disabilities.includes(:disability).find do |trainee_disability|
        trainee_disability.disability.name == Diversities::OTHER
      end
    end
  end
end
