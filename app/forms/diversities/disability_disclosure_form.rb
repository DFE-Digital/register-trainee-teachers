# frozen_string_literal: true

module Diversities
  class DisabilityDisclosureForm < TraineeForm
    FIELDS = %i[
      disability_disclosure
    ].freeze

    attr_accessor(*FIELDS)

    validates :disability_disclosure,
              presence: true,
              inclusion: { in: Diversities::DISABILITY_DISCLOSURE_ENUMS.values },
              if: -> { disclosure_form.diversity_disclosed? }

    def initialize(trainee, **kwargs)
      @disclosure_form = DisclosureForm.new(trainee)
      super(trainee, **kwargs)
    end

    def save!
      trainee.clear_disabilities if disability_not_provided? || no_disability?
      super
    end

    def disabled?
      fields[:disability_disclosure] == Diversities::DISABILITY_DISCLOSURE_ENUMS[:disabled]
    end

    def no_disability?
      fields[:disability_disclosure] == Diversities::DISABILITY_DISCLOSURE_ENUMS[:no_disability]
    end

    def disability_not_provided?
      fields[:disability_disclosure] == Diversities::DISABILITY_DISCLOSURE_ENUMS[:not_provided]
    end

  private

    attr_reader :disclosure_form

    def compute_fields
      trainee.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
    end

    def new_attributes
      if disclosure_form.diversity_disclosed?
        fields_from_store.merge(params).symbolize_keys
      else
        { disability_disclosure: nil }
      end
    end
  end
end
