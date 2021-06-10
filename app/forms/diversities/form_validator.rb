# frozen_string_literal: true

module Diversities
  class FormValidator
    include ActiveModel::Model

    FIELDS = {
      disclosure_section: DisclosureForm::FIELDS,
      ethnic_group_section: EthnicGroupForm::FIELDS,
      ethnic_background_section: EthnicBackgroundForm::FIELDS,
      disability_disclosure_section: DisabilityDisclosureForm::FIELDS,
    }.freeze

    attr_accessor(*(FIELDS.keys + FIELDS.values.flatten + %i[disability_ids]))

    attr_accessor :trainee, :fields

    delegate :id, :persisted?, to: :trainee

    validate :disclosure
    validate :ethnic_group, if: -> { disclosed_and_invalid? || trainee.ethnic_group.present? }
    validate :ethnic_background, if: -> { disclosed_and_invalid? || trainee.ethnic_background.present? }
    validate :disability_disclosure, if: -> { disclosed_and_invalid? || trainee.disability_disclosure.present? }
    validate :disabilities, if: -> { disability_disclosed_and_invalid? }

    def initialize(trainee)
      @trainee = trainee
      @fields = trainee.attributes
                       .symbolize_keys
                       .slice(*FIELDS.values.flatten)
                       .merge(disability_ids: trainee.disability_ids)
      super(fields)
    end

  private

    def disclosure
      return if validator_is_valid?(DisclosureForm)

      add_error_for(:disclosure_section)
    end

    def ethnic_group
      return if validator_is_valid?(EthnicGroupForm)

      add_error_for(:ethnic_group_section)
    end

    def ethnic_background
      return if validator_is_valid?(EthnicBackgroundForm)

      add_error_for(:ethnic_background_section)
    end

    def disability_disclosure
      return if validator_is_valid?(DisabilityDisclosureForm)

      add_error_for(:disability_disclosure_section)
    end

    def disabilities
      return if validator_is_valid?(DisabilityDetailForm)

      add_error_for(:disability_ids)
    end

    def validator_is_valid?(form_klass)
      form_klass.new(trainee).valid?
    end

    def add_error_for(key)
      errors.add(key, :not_valid)
    end

    def disclosed_and_invalid?
      trainee.diversity_disclosed? && (
        trainee.ethnic_group.blank? ||
        trainee.ethnic_background.blank? ||
        trainee.disability_disclosure.blank?
      )
    end

    def disability_disclosed_and_invalid?
      trainee.disabled? || trainee.disabilities.empty?
    end
  end
end
