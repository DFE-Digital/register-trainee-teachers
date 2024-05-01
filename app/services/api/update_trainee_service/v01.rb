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
        if validation_errors.any?
          [false, OpenStruct.new(
            error_count: validation_errors.count,
            all_errors: validation_errors,
          )]
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

      def validation
        @validation ||= Submissions::ApiTrnValidator.new(trainee:)
      end
    end
  end
end
