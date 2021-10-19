# frozen_string_literal: true

module Funding
  class FormValidator
    include ActiveModel::Model

    attr_accessor :trainee, :fields, :bursary_form, :training_initiatives_form

    delegate :id, :persisted?, to: :trainee
    delegate :applying_for_bursary, :applying_for_scholarship,
             :applying_for_grant, :bursary_tier,
             to: :bursary_form
    delegate :training_initiative, to: :training_initiatives_form

    validate :validate_training_initiative
    validate :validate_funding, if: -> { funding_manager.can_apply_for_funding_type? }

    def initialize(trainee)
      @trainee = trainee
      @bursary_form = BursaryForm.new(trainee)
      @training_initiatives_form = TrainingInitiativesForm.new(trainee)
      @fields = bursary_form_fields.merge(training_initiatives_form_fields)
    end

    def save!
      funding_forms.each(&:save!)
    end

    def missing_fields
      [
        funding_forms.flat_map do |form|
          form.valid?
          form.errors.attribute_names
        end,
      ]
    end

  private

    def funding_forms
      [
        training_initiatives_form,
        (bursary_form if funding_manager.can_apply_for_bursary? || funding_manager.can_apply_for_grant?),
      ].compact
    end

    def validate_funding
      return if bursary_form.valid?

      errors.add(:applying_for_bursary, :inclusion)
      errors.add(:applying_for_grant, :inclusion)
    end

    def validate_training_initiative
      errors.add(:training_initiative, :blank) unless training_initiatives_form.valid?
    end

    def bursary_form_fields
      bursary_form.fields || {}
    end

    def training_initiatives_form_fields
      training_initiatives_form.fields || {}
    end

    def funding_manager
      @funding_manager ||= FundingManager.new(trainee)
    end
  end
end
