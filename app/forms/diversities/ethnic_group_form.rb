# frozen_string_literal: true

module Diversities
  class EthnicGroupForm < TraineeForm
    FIELDS = %i[
      ethnic_group
      ethnic_background
      additional_ethnic_background
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
      (disclosure_form.diversity_disclosed? ? fields_from_store.merge(params).symbolize_keys : { ethnic_group: nil }).tap do |attrs|
        if attrs[:ethnic_group] == Diversities::ETHNIC_GROUP_ENUMS[:not_provided]
          attrs.merge!(ethnic_background: nil, additional_ethnic_background: nil)
        end
      end
    end
  end
end
