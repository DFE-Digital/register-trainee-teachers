# frozen_string_literal: true

module Funding
  class FormValidator
    include ActiveModel::Model

    attr_accessor :trainee, :fields, :bursary_form, :training_initiatives_form, :funding_eligibility_form

    delegate :id, :persisted?, to: :trainee
    delegate :applying_for_bursary, :applying_for_scholarship,
             :applying_for_grant, :bursary_tier,
             to: :bursary_form
    delegate :training_initiative, to: :training_initiatives_form
    delegate :funding_eligibility, to: :funding_eligibility_form

    # Only with the eligibility step, and not when no question is asked.
    validate :validate_funding_eligibility, if: :eligibility_question?
    validate :validate_training_initiative
    validate :validate_funding, if: -> { funding_manager.can_apply_for_funding_type? }
    # Draft funding that depends on a missing degree or employing school isn't complete,
    # even when it was marked complete before the detail was removed.
    validate :validate_funding_prerequisites, if: -> { trainee.draft? }

    def initialize(trainee)
      @trainee = trainee
      # First: the bursary form class depends on the eligibility answer.
      @funding_eligibility_form = EligibilityForm.new(trainee)
      @bursary_form = bursary_form_class.new(trainee)
      @training_initiatives_form = TrainingInitiativesForm.new(trainee)

      @fields = funding_eligibility_form_fields
        .merge(bursary_form_fields)
        .merge(training_initiatives_form_fields)
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
        (funding_eligibility_form if eligibility_question?),
        training_initiatives_form,
        (bursary_form if funding_manager.can_apply_for_bursary? || funding_manager.can_apply_for_grant?),
      ].compact
    end

    def validate_funding
      return if bursary_form.valid?

      errors.add(:applying_for_bursary, :inclusion)
      errors.add(:applying_for_grant, :inclusion)
    end

    def eligibility_step?
      FeatureService.enabled?(:funding_eligibility_step)
    end

    def eligibility_question?
      eligibility_step? && !funding_manager.eligibility_informational?
    end

    def validate_funding_eligibility
      errors.add(:funding_eligibility, :blank) unless funding_eligibility_form.valid?
    end

    def funding_eligibility_form_fields
      funding_eligibility_form.fields || {}
    end

    def validate_funding_prerequisites
      funding_manager.funding_prerequisites.each do |prerequisite|
        errors.add(:base, I18n.t("views.forms.funding.prerequisites.#{prerequisite}.summary"))
      end
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
      @funding_manager ||= if eligibility_step?
                             FundingManager.new(trainee, funding_eligibility: funding_eligibility_form.funding_eligibility)
                           else
                             FundingManager.new(trainee)
                           end
    end

    def grant_and_tiered_bursary?
      funding_manager.applicable_available_funding == :grant_and_tiered_bursary
    end

    def bursary_form_class
      grant_and_tiered_bursary? ? ::Funding::GrantAndTieredBursaryForm : ::Funding::BursaryForm
    end
  end
end
