# frozen_string_literal: true

module Api
  module UpdateTraineeService
    class V01
      include ServicePattern

      def initialize(trainee:, attributes:)
        @trainee = trainee
        @attributes = attributes
      end

      def call
        @trainee.update!(@attributes.attributes.select { |_k, v| v.present? })
      end
    end
  end
end
