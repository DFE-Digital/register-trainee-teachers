# frozen_string_literal: true

module Diversities
  class EthnicBackgroundForm
    include ActiveModel::Model
    include ActiveModel::AttributeAssignment
    include ActiveModel::Validations::Callbacks

    FIELDS = %w[
      ethnic_background
      additional_ethnic_background
    ].freeze

    attr_accessor(*FIELDS, :trainee)

    delegate :id, :persisted?, to: :trainee

    validates :ethnic_background, presence: true

    after_validation :update_trainee, if: -> { errors.empty? }

    def initialize(trainee:)
      @trainee = trainee
      super(fields)
    end

    def fields
      {
        ethnic_background: trainee.ethnic_background,
        additional_ethnic_background: trainee.additional_ethnic_background,
      }
    end

    def save
      valid? && trainee.save
    end

  private

    def update_trainee
      trainee.assign_attributes({
        ethnic_background: ethnic_background,
        additional_ethnic_background: additional_ethnic_background.presence,
      })
    end
  end
end
