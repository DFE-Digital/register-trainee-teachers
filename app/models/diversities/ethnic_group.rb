module Diversities
  class EthnicGroup
    include ActiveModel::Model
    attr_accessor :trainee

    FIELDS = %w[
      ethnic_group
    ].freeze

    attr_accessor(*FIELDS)

    validates :ethnic_group, presence: true, inclusion: { in: Diversities::ETHNIC_GROUP_ENUMS.values }

    delegate :id, :persisted?, to: :trainee

    def initialize(trainee:)
      @trainee = trainee
      super(trainee.attributes.slice(*FIELDS))
    end
  end
end
