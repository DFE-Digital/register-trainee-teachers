# frozen_string_literal: true

module Partners
  class LeadPartnerForm < Form
    FIELDS = %i[
      lead_partner_id
      lead_partner_not_applicable
    ].freeze

    attr_accessor(*FIELDS)

    validates :lead_partner_id, presence: true, if: :lead_partner_validation_required?

    alias_method :partner_id, :lead_partner_id
    alias_method :partner_not_applicable, :lead_partner_not_applicable

  private

    def compute_fields
      trainee.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
    end
  end
end
