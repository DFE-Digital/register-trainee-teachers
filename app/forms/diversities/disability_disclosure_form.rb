# frozen_string_literal: true

module Diversities
  class DisabilityDisclosureForm
    include ActiveModel::Model

    FIELDS = %i[
      disability_disclosure
    ].freeze

    attr_accessor(*FIELDS)

    attr_reader :trainee, :fields

    validates :disability_disclosure, presence: true, inclusion: { in: Diversities::DISABILITY_DISCLOSURE_ENUMS.values }

    delegate :id, :persisted?, to: :trainee

    def initialize(trainee, params = {}, store = FormStore)
      @trainee = trainee
      @store = store
      new_attributes = fields_from_store.merge(params).symbolize_keys
      @fields = trainee.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
      super(fields)
    end

    def save!
      if valid?
        trainee.assign_attributes(fields)
        trainee.save!
        store.set(trainee.id, :disability_disclosure, nil)
      else
        false
      end
    end

    def stash
      valid? && store.set(trainee.id, :disability_disclosure, fields)
    end

    def disabled?
      fields[:disability_disclosure] == Diversities::DISABILITY_DISCLOSURE_ENUMS[:disabled]
    end

    def no_disability?
      fields[:disability_disclosure] == Diversities::DISABILITY_DISCLOSURE_ENUMS[:no_disability]
    end

    def disability_not_provided?
      fields[:disability_disclosure] == Diversities::DISABILITY_DISCLOSURE_ENUMS[:not_provided]
    end

  private

    attr_reader :store

    def fields_from_store
      store.get(id, :disability_disclosure).presence || {}
    end
  end
end
