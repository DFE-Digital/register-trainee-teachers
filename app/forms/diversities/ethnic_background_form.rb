# frozen_string_literal: true

module Diversities
  class EthnicBackgroundForm
    include ActiveModel::Model
    include ActiveModel::AttributeAssignment
    include ActiveModel::Validations::Callbacks

    FIELDS = %i[
      ethnic_background
      additional_ethnic_background
    ].freeze

    attr_accessor(*FIELDS)

    attr_reader :trainee, :fields

    delegate :id, :persisted?, to: :trainee
    delegate :ethnic_group, to: :ethnic_group_form

    validates :ethnic_background, presence: true, if: -> { disclosure_form.diversity_disclosed? }

    def initialize(trainee, params = {}, store = FormStore)
      @trainee = trainee
      @store = store
      @params = params
      @disclosure_form = DisclosureForm.new(trainee)
      @ethnic_group_form = EthnicGroupForm.new(trainee)
      @fields = trainee.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
      super(fields)
    end

    def save!
      if valid?
        trainee.assign_attributes(fields)
        trainee.save!
        store.set(trainee.id, :ethnic_background, nil)
      else
        false
      end
    end

    def stash
      valid? && store.set(trainee.id, :ethnic_background, fields)
    end

  private

    attr_reader :store, :params, :disclosure_form, :ethnic_group_form

    def new_attributes
      if disclosure_form.diversity_disclosed?
        fields_from_store.merge(params).symbolize_keys
      else
        { ethnic_background: nil, additional_ethnic_background: nil }
      end
    end

    def fields_from_store
      store.get(id, :ethnic_background).presence || {}
    end
  end
end
