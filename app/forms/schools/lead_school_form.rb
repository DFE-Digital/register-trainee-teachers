# frozen_string_literal: true

module Schools
  class LeadSchoolForm < Form
    FIELDS = %i[
      lead_school_id
    ].freeze

    attr_accessor(*FIELDS)

    validates :lead_school_id, presence: true, unless: -> { school_not_selected? }

    alias_method :school_id, :lead_school_id

  private

    def compute_fields
      trainee.attributes.symbolize_keys.slice(:lead_school_id).merge(new_attributes)
    end
  end
end
