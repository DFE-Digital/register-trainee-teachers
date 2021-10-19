# frozen_string_literal: true

module Schools
  class EmployingSchoolForm < Form
    FIELDS = %i[
      employing_school_id
      employing_school_not_applicable
    ].freeze

    attr_accessor(*FIELDS)

    alias_method :school_id, :employing_school_id
    alias_method :school_not_applicable, :employing_school_not_applicable

  private

    def compute_fields
      trainee.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
    end
  end
end
