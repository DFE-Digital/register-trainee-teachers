# frozen_string_literal: true

module Diversities
  module DisabilityDetails
    class Update
      include ServicePattern

      attr_reader :trainee, :disability_detail, :successful

      alias_method :successful?, :successful

      def initialize(trainee:, attributes: {})
        @trainee = trainee
        trainee.assign_attributes(attributes)
        @disability_detail = Diversities::DisabilityDetail.new(trainee: trainee)
      end

      def call
        @successful = disability_detail.valid? && trainee.save!
        self
      end
    end
  end
end
