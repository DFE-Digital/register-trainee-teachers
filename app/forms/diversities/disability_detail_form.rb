# frozen_string_literal: true

module Diversities
  class DisabilityDetailForm
    include ActiveModel::Model
    include ActiveModel::AttributeAssignment
    include ActiveModel::Validations::Callbacks

    attr_accessor :disability_ids, :additional_disability

    attr_reader :trainee, :fields

    delegate :id, :persisted?, to: :trainee

    validate :disabilities_cannot_be_empty, if: -> { disability_disclosure_form.disabled? && disabilities.empty? }

    def initialize(trainee, params = {}, store = FormStore)
      @trainee = trainee
      @store = store
      @params = params
      @disability_disclosure_form = DisabilityDisclosureForm.new(trainee)
      @fields = {
        disability_ids: trainee.disability_ids,
        additional_disability: other_trainee_disability&.additional_disability,
      }.merge(new_attributes)

      super(fields)
    end

    def save!
      if valid?
        Trainee.transaction do
          trainee.disability_ids = fields[:disability_ids] # This will actually persist the records
          other_trainee_disability&.update!(additional_disability: fields[:additional_disability])
        end

        store.set(trainee.id, :disability_detail, nil)

        true
      else
        false
      end
    end

    def stash
      valid? && store.set(id, :disability_detail, fields)
    end

    def disabilities
      Disability.where(id: disability_ids)
    end

  private

    attr_reader :store, :params, :disability_disclosure_form

    def new_attributes
      if disability_disclosure_form.disabled?
        fields_from_store.merge(params).symbolize_keys.tap do |f|
          f[:disability_ids] = f[:disability_ids].reject(&:blank?).map(&:to_i) if f[:disability_ids]
        end
      else
        { disability_ids: [], additional_disability: nil }
      end
    end

    def disabilities_cannot_be_empty
      errors.add(:disability_ids, :empty_disabilities)
    end

    def other_trainee_disability
      @other_trainee_disability ||= trainee.trainee_disabilities.includes(:disability).find do |trainee_disability|
        trainee_disability.disability.name == Diversities::OTHER
      end
    end

    def fields_from_store
      store.get(id, :disability_detail).presence || {}
    end
  end
end
