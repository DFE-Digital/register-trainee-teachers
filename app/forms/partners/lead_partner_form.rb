# frozen_string_literal: true

module Partners
  class LeadPartnerForm < Form
    LEAD_PARTNER_NOT_APPLICABLE_OPTION = Struct.new(:id, :name)

    FIELDS = %i[
      lead_partner_id
      lead_partner_not_applicable
    ].freeze

    attr_accessor(*FIELDS)

    validates :lead_partner_id, presence: true, if: :lead_partner_validation_required?

    def lead_partner_not_applicable_options
      [true, false].map do |value|
        LEAD_PARTNER_NOT_APPLICABLE_OPTION.new(id: value, name: value ? "No" : "Yes")
      end
    end

  private

    def compute_fields
      trainee.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
    end
  end
end
