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
        trainee.assign_attributes(attributes.deep_attributes)

        if validation.all_errors.any?
          [false, validation]
        else
          [trainee.save, nil]
        end
      end

    private

      attr_reader :trainee, :attributes

      def validation
        @validation ||= Submissions::ApiTrnValidator.new(trainee:)
      end
    end
  end
end
