module Diversities
  class Disclosure
    include ActiveModel::Model
    attr_accessor :trainee

    FIELDS = %w[
      diversity_disclosure
    ].freeze

    attr_accessor(*FIELDS)

    validates :diversity_disclosure, presence: true, inclusion: { in: Diversities::DIVERSITY_DISCLOSURE_ENUMS.values }

    delegate :id, :persisted?, to: :trainee

    def initialize(trainee:)
      @trainee = trainee
      super(trainee.attributes.slice(*FIELDS))
    end
  end
end
