# frozen_string_literal: true

module Schools
  class EmployingSchoolForm < Form
    FIELDS = %i[
      employing_school_id
    ].freeze

    attr_accessor(*FIELDS)

    validates :employing_school_id, presence: true, unless: -> { school_not_selected? }

    alias_method :school_id, :employing_school_id

  private

    def compute_fields
      trainee.attributes.symbolize_keys.slice(:employing_school_id).merge(new_attributes)
    end
  end
end
