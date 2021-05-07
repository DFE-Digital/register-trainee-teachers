# frozen_string_literal: true

module Schools
  class FormValidator
    include ActiveModel::Model

    FIELDS = {
      lead_school_section: LeadSchoolForm::FIELDS,
      employing_school_section: EmployingSchoolForm::FIELDS,
    }.freeze

    attr_accessor(*(FIELDS.keys + FIELDS.values.flatten))

    attr_accessor :trainee, :fields

    delegate :id, :persisted?, to: :trainee

    validate :lead_school, if: -> { trainee.requires_schools? }
    validate :employing_school, if: -> { trainee.requires_employing_school? }

    def initialize(trainee)
      @trainee = trainee
      @fields = trainee.attributes.symbolize_keys.slice(*FIELDS.values.flatten)
      super(fields)
    end

  private

    def lead_school
      return if LeadSchoolForm.new(trainee).valid?

      errors.add(:lead_school_section, :not_valid)
    end

    def employing_school
      return if EmployingSchoolForm.new(trainee).valid?

      errors.add(:employing_school_section, :not_valid)
    end
  end
end
