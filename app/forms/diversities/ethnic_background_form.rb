# frozen_string_literal: true

module Diversities
  class EthnicBackgroundForm < TraineeForm
    FIELDS = %i[
      ethnic_background
      additional_ethnic_background
    ].freeze

    attr_accessor(*FIELDS)

    delegate :ethnic_group, to: :ethnic_group_form

    validates :ethnic_background, presence: true, if: -> { disclosure_form.diversity_disclosed? }

    def initialize(trainee, **kwargs)
      @disclosure_form = DisclosureForm.new(trainee)
      @ethnic_group_form = EthnicGroupForm.new(trainee)
      super(trainee, **kwargs)
    end

  private

    attr_reader :disclosure_form, :ethnic_group_form

    def compute_fields
      trainee.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
    end

    def new_attributes
      if disclosure_form.diversity_disclosed?
        fields_from_store.merge(params).symbolize_keys
      else
        { ethnic_background: nil, additional_ethnic_background: nil }
      end
    end
  end
end
