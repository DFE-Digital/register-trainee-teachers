# frozen_string_literal: true

module Diversities
  class EthnicGroupForm < TraineeForm
    FIELDS = %i[
      ethnic_group
    ].freeze

    attr_accessor(*FIELDS)

    validates :ethnic_group,
              presence: true,
              inclusion: { in: Diversities::ETHNIC_GROUP_ENUMS.values },
              if: -> { disclosure_form.diversity_disclosed? }

    def initialize(trainee, **kwargs)
      @disclosure_form = DisclosureForm.new(trainee)
      super(trainee, **kwargs)
    end

    def not_provided_ethnic_group?
      fields[:ethnic_group] == Diversities::ETHNIC_GROUP_ENUMS[:not_provided]
    end

  private

    attr_reader :disclosure_form

    def compute_fields
      trainee.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
    end

    def new_attributes
      disclosure_form.diversity_disclosed? ? fields_from_store.merge(params).symbolize_keys : { ethnic_group: nil }
    end
  end
end
