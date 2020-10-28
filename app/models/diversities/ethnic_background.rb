module Diversities
  class EthnicBackground
    include ActiveModel::Model
    attr_accessor :trainee, :ethnic_background

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
