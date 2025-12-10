# frozen_string_literal: true

module Schools
  class FormValidator
    include ActiveModel::Model

    attr_accessor :trainee, :fields, :training_partner_form, :employing_school_form

    delegate :id, :persisted?, to: :trainee

    validate :validate_training_partner, if: -> { trainee.requires_training_partner? }
    validate :validate_employing_school, if: -> { trainee.requires_employing_school? }

    delegate :training_partner_id, to: :training_partner_form
    delegate :employing_school_id, to: :employing_school_form

    def initialize(trainee, non_search_validation: false)
      @trainee = trainee
      @training_partner_form = ::Partners::TrainingPartnerForm.new(trainee, params: { non_search_validation: })
      @employing_school_form = EmployingSchoolForm.new(trainee, params: { non_search_validation: })
      @fields = training_partner_form_fields.merge(employing_school_form_fields).except(:non_search_validation)
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
      training_partner_form.save!
      employing_school_form.save!
    end

  private

    def school_forms
      [
        (training_partner_form if trainee.requires_training_partner?),
        (employing_school_form if trainee.requires_employing_school?),
      ].compact
    end

    def validate_training_partner
      errors.add(:training_partner_id, :not_valid) unless training_partner_form.valid?
    end

    def validate_employing_school
      errors.add(:employing_school_id, :not_valid) unless employing_school_form.valid?
    end

    def training_partner_form_fields
      training_partner_form.fields || {}
    end

    def employing_school_form_fields
      employing_school_form.fields || {}
    end
  end
end
