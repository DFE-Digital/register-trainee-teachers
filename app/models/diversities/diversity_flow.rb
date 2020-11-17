module Diversities
  class DiversityFlow
    include ActiveModel::Model

    FIELDS = {
      disclosure_section: Diversities::Disclosure::FIELDS,
      ethnic_group_section: Diversities::EthnicGroup::FIELDS,
      ethnic_background_section: Diversities::EthnicBackground::FIELDS,
      disability_disclosure_section: Diversities::DisabilityDisclosure::FIELDS,
    }.freeze

    attr_accessor(*(FIELDS.keys + FIELDS.values.flatten + %i[trainee disability_ids]))

    delegate :id, :persisted?, to: :trainee

    validate :disclosure
    validate :ethnic_group, if: -> { trainee.ethnic_group.present? }
    validate :ethnic_background, if: -> { trainee.ethnic_background.present? }
    validate :disability_disclosure, if: -> { trainee.disability_disclosure.present? }
    validate :disabilities, if: -> { trainee.disabled? }

    def initialize(trainee)
      @trainee = trainee
      super(fields)
    end

    def fields
      trainee.attributes.slice(*FIELDS.values.flatten).merge(disability_ids: trainee.disability_ids)
    end

  private

    def disclosure
      return if validator_is_valid?(Disclosure)

      add_error_for(:disclosure_section)
    end

    def ethnic_group
      return if validator_is_valid?(EthnicGroup)

      add_error_for(:ethnic_group_section)
    end

    def ethnic_background
      return if validator_is_valid?(EthnicBackground)

      add_error_for(:ethnic_background_section)
    end

    def disability_disclosure
      return if validator_is_valid?(DisabilityDisclosure)

      add_error_for(:disability_disclosure_section)
    end

    def disabilities
      return if validator_is_valid?(DisabilityDetail)

      add_error_for(:disability_ids)
    end

    def validator_is_valid?(error_klass)
      error_klass.new(trainee: trainee).valid?
    end

    def add_error_for(key)
      errors.add(key, :not_valid)
    end
  end
end
