# frozen_string_literal: true

module Partners
  class TrainingPartnerForm < Form
    TRAINING_PARTNER_NOT_APPLICABLE_OPTION = Struct.new(:id, :name)

    FIELDS = %i[
      training_partner_id
      training_partner_not_applicable
    ].freeze

    attr_accessor(*FIELDS)

    validates :training_partner_id, presence: true, if: :training_partner_validation_required?

    def training_partner_not_applicable_options
      [true, false].map do |value|
        TRAINING_PARTNER_NOT_APPLICABLE_OPTION.new(id: value, name: value ? "No" : "Yes")
      end
    end

  private

    def compute_fields
      trainee.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
    end
  end
end
