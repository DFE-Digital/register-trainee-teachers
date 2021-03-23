# frozen_string_literal: true

module Diversities
  class EthnicGroupForm
    include ActiveModel::Model

    FIELDS = %i[
      ethnic_group
    ].freeze

    attr_accessor(*FIELDS)

    attr_reader :trainee, :fields

    validates :ethnic_group, presence: true, inclusion: { in: Diversities::ETHNIC_GROUP_ENUMS.values }

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
        trainee.assign_attributes(nullify_ethnic_background(fields))
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

    attr_reader :store

    def nullify_ethnic_background(fields)
      return fields.merge(ethnic_background: nil, additional_ethnic_background: nil) unless trainee.ethnic_group == fields[:ethnic_group]

      fields
    end

    def fields_from_store
      store.get(id, :ethnic_group).presence || {}
    end
  end
end
