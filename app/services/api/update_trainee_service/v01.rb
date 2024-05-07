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
        trainee_attributes_validation = TraineeAttributesValidation.new(trainee_attributes:)
        if trainee_attributes_validation.invalid?
          [false, trainee_attributes_validation]
        else
          trainee.assign_attributes(attributes.deep_attributes)

          if validation.all_errors.any?
            [false, validation]
          else
            [trainee.save, nil]
          end
        end
      end

    private

      attr_reader :trainee, :attributes

      alias_method :trainee_attributes, :attributes

      TraineeAttributesValidation = Struct.new(:trainee_attributes) do
        def errors_count = validation_errors.count
        def all_errors = validation_errors
        def invalid? = !errors_count.zero?

        def validation_errors
          [*trainee_errors, *hesa_trainee_detail_attributes_errors].compact.flatten
        end

        def trainee_errors
          @trainee_errors ||= begin
            trainee_attributes.validate
            trainee_attributes.errors&.full_messages
          end
        end

        def hesa_trainee_detail_attributes_errors
          @hesa_trainee_detail_attributes_errors ||= begin
            trainee_attributes.hesa_trainee_detail_attributes.validate
            trainee_attributes.hesa_trainee_detail_attributes.errors&.full_messages
          end
        end
      end

      def validation
        @validation ||= Submissions::ApiTrnValidator.new(trainee:)
      end
    end
  end
end
