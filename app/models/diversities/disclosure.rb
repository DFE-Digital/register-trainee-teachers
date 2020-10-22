module Diversities
  class Disclosure
    include ActiveModel::Model
    attr_accessor :trainee, :diversity_disclosure

    validates :diversity_disclosure, presence: true, inclusion: { in: Trainee.diversity_disclosures.keys }

    delegate :id, :persisted?, to: :trainee

    def initialize(trainee:)
      @trainee = trainee
      super(diversity_disclosure: trainee.diversity_disclosure)
    end
  end
end
