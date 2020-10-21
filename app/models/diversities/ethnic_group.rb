module Diversities
  class EthnicGroup
    include ActiveModel::Model
    attr_accessor :trainee, :ethnic_group

    validates :ethnic_group, presence: true, inclusion: { in: Trainee.ethnic_groups.keys }

    delegate :id, :persisted?, to: :trainee

    def initialize(trainee:)
      @trainee = trainee
      super(ethnic_group: trainee.ethnic_group)
    end
  end
end
