module Diversities
  module EthnicGroups
    class Update
      attr_reader :trainee, :ethnic_group, :successful

      alias_method :successful?, :successful

      class << self
        def call(...)
          new(...).call
        end
      end

      def initialize(trainee:, attributes: {})
        @trainee = trainee
        trainee.assign_attributes(attributes)
        @ethnic_group = Diversities::EthnicGroup.new(trainee: trainee)
      end

      def call
        @successful = ethnic_group.valid? && trainee.save!
        self
      end
    end
  end
end
