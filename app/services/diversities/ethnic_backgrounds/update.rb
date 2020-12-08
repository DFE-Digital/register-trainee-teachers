# frozen_string_literal: true

module Diversities
  module EthnicBackgrounds
    class Update
      include ServicePattern

      attr_reader :trainee, :ethnic_background, :successful

      alias_method :successful?, :successful

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
