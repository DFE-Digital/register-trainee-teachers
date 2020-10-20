module Diversities
  module Disclosures
    class Update
      attr_reader :trainee, :disclosure, :successful

      alias_method :successful?, :successful

      class << self
        def call(...)
          new(...).call
        end
      end

      def initialize(trainee:, attributes: {})
        @trainee = trainee
        trainee.assign_attributes(attributes)
        @disclosure = Diversities::Disclosure.new(trainee: trainee)
      end

      def call
        @successful = disclosure.valid? && trainee.save!
        self
      end
    end
  end
end
