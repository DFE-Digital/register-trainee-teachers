# frozen_string_literal: true

module Funding
  class FormValidator
    include ActiveModel::Model

    attr_accessor :trainee, :fields, :bursary_form, :training_initiatives_form

    delegate :id, :persisted?, to: :trainee

    validate :validate_bursary, if: -> { trainee.bursary_amount.present? }
    validate :validate_training_initiative

    delegate :applying_for_bursary, to: :bursary_form
    delegate :training_initiative, to: :training_initiatives_form

    def initialize(trainee)
      @trainee = trainee
      @bursary_form = BursaryForm.new(trainee)
      @training_initiatives_form = TrainingInitiativesForm.new(trainee)
      @fields = bursary_form_fields.merge(training_initiatives_form_fields)
    end

    def missing_fields
      bursary_forms.flat_map do |form|
        form.valid?
        form.errors.attribute_names
      end
    end

  private

    def bursary_forms
      [
        training_initiatives_form,
        (bursary_form if trainee.can_apply_for_bursary?),
      ].compact
    end

    def validate_bursary
      errors.add(:applying_for_bursary, :inclusion) unless bursary_form.valid?
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
  end
end
