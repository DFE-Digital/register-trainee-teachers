# frozen_string_literal: true

module Diversities
  class DisabilityDetailForm
    include ActiveModel::Model
    include ActiveModel::AttributeAssignment
    include ActiveModel::Validations::Callbacks

    attr_accessor :trainee, :disability_ids, :additional_disability

    delegate :id, :persisted?, to: :trainee
    validate :disabilities_cannot_be_empty

    def initialize(trainee:, attributes: {})
      @trainee = trainee
      @attributes = attributes
      super(fields)
    end

    def fields
      {
        disability_ids: disabilities,
        additional_disability: additional_disability_value,
      }
    end

    def save
      if valid?
        Trainee.transaction do
          update_disabilities
          update_additional_disability_info if other_trainee_disability.present?
        end

        true
      else
        false
      end
    end

  private

    attr_reader :attributes

    def disabilities_cannot_be_empty
      return unless disabilities.empty?

      errors.add(:disability_ids, :empty_disabilities)
    end

    def disabilities
      return trainee.disability_ids if attributes[:disability_ids].blank?

      attributes[:disability_ids].reject(&:blank?).map(&:to_i)
    end

    def other_trainee_disability
      @other_trainee_disability ||= trainee.trainee_disabilities.includes(:disability).find do |trainee_disability|
        trainee_disability.disability.name == Diversities::OTHER
      end
    end

    def additional_disability_value
      return other_trainee_disability&.additional_disability if attributes[:additional_disability].nil?

      attributes[:additional_disability]
    end

    def update_disabilities
      # This will actually persist the records due to how the association *_ids=() method works.
      trainee.assign_attributes(disability_ids: disabilities)
    end

    def update_additional_disability_info
      other_trainee_disability.update(additional_disability: additional_disability_value)
    end
  end
end
