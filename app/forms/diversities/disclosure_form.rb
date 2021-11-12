# frozen_string_literal: true

module Diversities
  class DisclosureForm < TraineeForm
    FIELDS = %i[
      diversity_disclosure
    ].freeze

    attr_accessor(*FIELDS)

    validates :diversity_disclosure, presence: true, inclusion: { in: Diversities::DIVERSITY_DISCLOSURE_ENUMS.values }

    def diversity_disclosed?
      diversity_disclosure == Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_disclosed]
    end

    def diversity_not_disclosed?
      diversity_disclosure == Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_not_disclosed]
    end

    def save!
      if valid?
        save_trainee!
        clear_stash
      else
        false
      end
    end

  private

    def save_trainee!
      trainee.assign_attributes(fields.except(*fields_to_ignore_before_save))
      trainee.disability_disclosure = diversity_not_disclosed? ? Diversities::DISABILITY_DISCLOSURE_ENUMS[:not_provided] : nil
      trainee.save!
    end

    def compute_fields
      trainee.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
    end

    def form_store_key
      :diversity_disclosure
    end
  end
end
