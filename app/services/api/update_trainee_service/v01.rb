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
        if @attributes.valid?
          [@trainee.update(@attributes.attributes), @trainee.errors&.full_messages]
        else
          [false, @attributes.errors.full_messages]
        end
      end
    end
  end
end
