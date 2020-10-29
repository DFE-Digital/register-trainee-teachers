module Diversities
  module DisabilityDisclosures
    class Update
      attr_reader :trainee, :disability_disclosure, :successful

      alias_method :successful?, :successful

      class << self
        def call(**args)
          new(**args).call
        end
      end

      def initialize(trainee:, attributes: {})
        @trainee = trainee
        trainee.assign_attributes(attributes)
        @disability_disclosure = Diversities::DisabilityDisclosure.new(trainee: trainee)
      end

      def call
        @successful = disability_disclosure.valid? && trainee.save!
        self
      end
    end
  end
end
