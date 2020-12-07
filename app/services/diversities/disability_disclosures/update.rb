# frozen_string_literal: true

module Diversities
  module DisabilityDisclosures
    class Update
      include ServicePattern

      attr_reader :trainee, :disability_disclosure, :successful

      alias_method :successful?, :successful

      def initialize(trainee:, attributes: {})
        @trainee = trainee
        @attributes = attributes
        trainee.assign_attributes(attributes)
        @disability_disclosure = Diversities::DisabilityDisclosure.new(trainee: trainee)
      end

      def call
        trainee.disabilities.clear if not_disabled? || disability_not_provided?
        @successful = disability_disclosure.valid? && trainee.save!
        self
      end

    private

      attr_reader :attributes

      def not_disabled?
        attributes[:disability_disclosure] == Diversities::DISABILITY_DISCLOSURE_ENUMS[:not_disabled]
      end

      def disability_not_provided?
        attributes[:disability_disclosure] == Diversities::DISABILITY_DISCLOSURE_ENUMS[:not_provided]
      end
    end
  end
end
