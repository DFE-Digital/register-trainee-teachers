# frozen_string_literal: true

module Diversities
  class EthnicBackground
    include ActiveModel::Model
    attr_accessor :trainee

    FIELDS = %w[
      ethnic_background
      additional_ethnic_background
    ].freeze

    attr_accessor(*FIELDS)

    delegate :id, :persisted?, to: :trainee

    validates :ethnic_background, presence: true

    def initialize(trainee:)
      @trainee = trainee
      super(trainee.attributes.slice(*FIELDS))
    end
  end
end
