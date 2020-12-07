# frozen_string_literal: true

module Diversities
  module EthnicGroups
    class Update
      include ServicePattern

      attr_reader :trainee, :ethnic_group, :successful

      alias_method :successful?, :successful

      def initialize(trainee:, attributes: {})
        @trainee = trainee
        trainee.assign_attributes(nullify_ethnic_background(attributes))
        @ethnic_group = Diversities::EthnicGroup.new(trainee: trainee)
      end

      def call
        @successful = ethnic_group.valid? && trainee.save!
        self
      end

    private

      def nullify_ethnic_background(attributes)
        return attributes.merge(ethnic_background: nil, additional_ethnic_background: nil) unless trainee.ethnic_group == attributes[:ethnic_group]

        attributes
      end
    end
  end
end
