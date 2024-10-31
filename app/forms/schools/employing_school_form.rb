# frozen_string_literal: true

module Schools
  class EmployingSchoolForm < Form
    EMPLOYING_SCHOOL_NOT_APPLICABLE_OPTION = Struct.new(:id, :name)

    FIELDS = %i[
      employing_school_id
      employing_school_not_applicable
    ].freeze

    attr_accessor(*FIELDS)

    validates :employing_school_id, presence: true, if: :school_validation_required?

    alias_method :school_id, :employing_school_id

    def school_not_applicable
      employing_school_not_applicable.to_s == "true"
    end

    def employing_school_not_applicable_options
      [true, false].map do |value|
        EMPLOYING_SCHOOL_NOT_APPLICABLE_OPTION.new(id: value, name: value ? "No" : "Yes")
      end
    end

  private

    def compute_fields
      trainee.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
    end
  end
end
