# frozen_string_literal: true

module Api
  module V20260
    class UpdateTraineeService
      include ServicePattern

      def initialize(trainee:, attributes:)
        @trainee = trainee
        @attributes = attributes
      end

      def call
        trainee_attributes_validation = TraineeAttributesValidation.new(trainee_attributes:)
        attributes_to_save = attributes.deep_attributes.with_indifferent_access
        trainee.nationalities.destroy_all if attributes_to_save[:nationalisations_attributes].present?
        trainee.clear_disabilities if attributes_to_save[:trainee_disabilities_attributes].present?

        if trainee_attributes_validation.invalid?
          [false, trainee_attributes_validation]
        else
          trainee.assign_attributes(attributes_to_save)
          trainee.disabilities = [] if !trainee.disabled? && trainee.disability_disclosure_changed?

          [trainee.save, trainee]
        end
      end

      TraineeAttributesValidation = Struct.new(:trainee_attributes) do
        def errors_count = validation_errors.count
        def all_errors = validation_errors
        def invalid? = !errors_count.zero?

        def validation_errors
          trainee_errors.compact.flatten.map(&:strip)
        end

        def trainee_errors
          @trainee_errors ||= begin
            trainee_attributes.validate
            trainee_attributes.errors&.full_messages
          end
        end
      end

    private

      attr_reader :trainee, :attributes

      alias_method :trainee_attributes, :attributes
    end
  end
end
