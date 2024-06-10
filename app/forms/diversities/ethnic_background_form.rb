# frozen_string_literal: true

module Diversities
  class EthnicBackgroundForm < TraineeForm
    FIELDS = %i[
      ethnic_background
      additional_ethnic_background
    ].freeze

    attr_accessor(*FIELDS)

    delegate :ethnic_group, to: :ethnic_group_form

    validates :ethnic_background, presence: true, if: :requires_ethnic_background?

    def initialize(trainee, **)
      @disclosure_form = DisclosureForm.new(trainee)
      @ethnic_group_form = EthnicGroupForm.new(trainee)
      super
    end

    def requires_ethnic_background?
      disclosure_form.diversity_disclosed? && ethnic_group_form.ethnic_group_disclosed?
    end

  private

    attr_reader :disclosure_form, :ethnic_group_form

    def compute_fields
      trainee.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
    end

    def new_attributes
      if requires_ethnic_background?
        fields_from_store.merge(params).symbolize_keys
      else
        { ethnic_background: nil, additional_ethnic_background: nil }
      end
    end
  end
end
