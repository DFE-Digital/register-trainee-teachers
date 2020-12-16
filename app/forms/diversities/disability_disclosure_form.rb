# frozen_string_literal: true

module Diversities
  class DisabilityDisclosureForm
    include ActiveModel::Model
    attr_accessor :trainee

    FIELDS = %w[
      disability_disclosure
    ].freeze

    attr_accessor(*FIELDS)

    validates :disability_disclosure, presence: true, inclusion: { in: Diversities::DISABILITY_DISCLOSURE_ENUMS.values }

    delegate :id, :persisted?, to: :trainee

    def initialize(trainee:)
      @trainee = trainee
      super(trainee.attributes.slice(*FIELDS))
    end
  end
end
