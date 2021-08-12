# frozen_string_literal: true

module Schools
  class FormValidator
    include ActiveModel::Model

    attr_accessor :trainee, :fields, :lead_school_form, :employing_school_form

    delegate :id, :persisted?, to: :trainee

    validate :validate_lead_school, if: -> { trainee.requires_schools? }
    validate :validate_employing_school, if: -> { trainee.requires_employing_school? }

    delegate :lead_school_id, to: :lead_school_form
    delegate :employing_school_id, to: :employing_school_form

    def initialize(trainee, non_search_validation: false)
      @trainee = trainee
      @lead_school_form = LeadSchoolForm.new(trainee, params: { non_search_validation: non_search_validation })
      @employing_school_form = EmployingSchoolForm.new(trainee, params: { non_search_validation: non_search_validation })
      @fields = lead_school_form_fields.merge(employing_school_form_fields)
    end

    def missing_fields
      [
        school_forms.flat_map do |form|
          form.valid?
          form.errors.attribute_names
        end,
      ]
    end

    def save!
      lead_school_form.save!
      employing_school_form.save!
    end

  private

    def school_forms
      [
        (lead_school_form if trainee.requires_schools?),
        (employing_school_form if trainee.requires_employing_school?),
      ].compact
    end

    def validate_lead_school
      errors.add(:lead_school_id, :not_valid) unless lead_school_form.valid?
    end

    def validate_employing_school
      errors.add(:employing_school_id, :not_valid) unless employing_school_form.valid?
    end

    def lead_school_form_fields
      lead_school_form.fields || {}
    end

    def employing_school_form_fields
      employing_school_form.fields || {}
    end
  end
end
