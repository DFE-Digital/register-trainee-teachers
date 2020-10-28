module Diversities
  module EthnicBackgrounds
    class Update
      attr_reader :trainee, :ethnic_background, :successful

      alias_method :successful?, :successful

      class << self
        def call(**args)
          new(**args).call
        end
      end

      def initialize(trainee:, attributes: {})
        @trainee = trainee
        trainee.assign_attributes(attributes)
        @ethnic_background = Diversities::EthnicBackground.new(trainee: trainee)
      end

      def call
        @successful = ethnic_background.valid? && trainee.save!
        self
      end
    end
  end
end
