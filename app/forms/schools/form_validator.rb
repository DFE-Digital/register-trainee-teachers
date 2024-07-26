# frozen_string_literal: true

module Schools
  class FormValidator
    include ActiveModel::Model

    attr_accessor :trainee, :fields, :lead_partner_form, :employing_school_form

    delegate :id, :persisted?, to: :trainee

    validate :validate_lead_partner, if: -> { trainee.requires_lead_partner? }
    validate :validate_employing_school, if: -> { trainee.requires_employing_school? }

    delegate :lead_partner_id, to: :lead_partner_form
    delegate :employing_school_id, to: :employing_school_form

    def initialize(trainee, non_search_validation: false)
      @trainee = trainee
      @lead_partner_form = ::Partners::LeadPartnerForm.new(trainee, params: { non_search_validation: })
      @employing_school_form = EmployingSchoolForm.new(trainee, params: { non_search_validation: })
      @fields = lead_partner_form_fields.merge(employing_school_form_fields).except(:non_search_validation)
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
      lead_partner_form.save!
      employing_school_form.save!
    end

  private

    def school_forms
      [
        (lead_partner_form if trainee.requires_lead_partner?),
        (employing_school_form if trainee.requires_employing_school?),
      ].compact
    end

    def validate_lead_partner
      errors.add(:lead_partner_id, :not_valid) unless lead_partner_form.valid?
    end

    def validate_employing_school
      errors.add(:employing_school_id, :not_valid) unless employing_school_form.valid?
    end

    def lead_partner_form_fields
      lead_partner_form.fields || {}
    end

    def employing_school_form_fields
      employing_school_form.fields || {}
    end
  end
end
