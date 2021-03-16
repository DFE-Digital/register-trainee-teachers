# frozen_string_literal: true

module Diversities
  class DisclosureForm
    include ActiveModel::Model

    FIELDS = %i[
      diversity_disclosure
    ].freeze

    attr_accessor(*FIELDS)

    attr_reader :trainee, :fields

    validates :diversity_disclosure, presence: true, inclusion: { in: Diversities::DIVERSITY_DISCLOSURE_ENUMS.values }

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
        store.set(id, :diversity_disclosure, nil)
      else
        false
      end
    end

    def stash
      valid? && store.set(id, :diversity_disclosure, fields)
    end

    def diversity_disclosed?
      diversity_disclosure == Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_disclosed]
    end

  private

    attr_reader :store

    def fields_from_store
      store.get(id, :diversity_disclosure).presence || {}
    end
  end
end
