# frozen_string_literal: true

module Schools
  class LeadSchoolForm < Form
    FIELDS = %i[
      lead_school_id
      lead_partner_not_applicable
    ].freeze

    attr_accessor(*FIELDS)

    validates :lead_school_id, presence: true, if: :school_validation_required?

    alias_method :school_id, :lead_school_id
    alias_method :school_not_applicable, :lead_partner_not_applicable

  private

    def compute_fields
      trainee.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
    end
  end
end
