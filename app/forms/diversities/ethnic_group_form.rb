# frozen_string_literal: true

module Diversities
  class EthnicGroupForm
    include ActiveModel::Model

    FIELDS = %i[
      ethnic_group
    ].freeze

    attr_accessor(*FIELDS)

    attr_reader :trainee, :fields

    validates :ethnic_group,
              presence: true,
              inclusion: { in: Diversities::ETHNIC_GROUP_ENUMS.values },
              if: -> { disclosure_form.diversity_disclosed? }

    delegate :id, :persisted?, to: :trainee

    def initialize(trainee, params = {}, store = FormStore)
      @trainee = trainee
      @store = store
      @params = params
      @disclosure_form = DisclosureForm.new(trainee)
      @fields = trainee.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
      super(fields)
    end

    def save!
      if valid?
        trainee.assign_attributes(fields)
        trainee.save!
        store.set(trainee.id, :ethnic_group, nil)
      else
        false
      end
    end

    def stash
      valid? && store.set(trainee.id, :ethnic_group, fields)
    end

    def not_provided_ethnic_group?
      fields[:ethnic_group] == Diversities::ETHNIC_GROUP_ENUMS[:not_provided]
    end

  private

    attr_reader :store, :params, :disclosure_form

    def new_attributes
      disclosure_form.diversity_disclosed? ? fields_from_store.merge(params).symbolize_keys : { ethnic_group: nil }
    end

    def fields_from_store
      store.get(id, :ethnic_group).presence || {}
    end
  end
end
