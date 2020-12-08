# frozen_string_literal: true

module Diversities
  module Disclosures
    class Update
      include ServicePattern

      attr_reader :trainee, :disclosure, :successful

      alias_method :successful?, :successful

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
