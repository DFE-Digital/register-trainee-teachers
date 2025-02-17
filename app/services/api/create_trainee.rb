# frozen_string_literal: true

module Api
  class CreateTrainee
    include ServicePattern
    include Serializable
    include ErrorResponse

    include ActiveModel::Model

    attr_accessor :current_provider, :trainee_attributes, :version

    def initialize(current_provider:, trainee_attributes:, version:)
      @current_provider = current_provider
      @trainee_attributes = trainee_attributes
      @version = version
    end

    def call
      return validation_error_response(trainee_attributes_errors) if trainee_attributes_errors.any?

      if duplicate_trainees.present?
        errors.add(:base, :duplicate)

        return conflict_errors_response(errors: errors, duplicates: duplicate_trainees)
      end

      trainee = current_provider.trainees.build(trainee_attributes.deep_attributes)
      validator = Submissions::ApiTrnValidator.new(trainee:)

      if validator.all_errors.empty? && trainee.save
        ::Trainees::SubmitForTrn.call(trainee:)
        success_response(trainee)
      else
        save_errors_response(validator, trainee)
      end
    end

  private

    def duplicate_trainees
      @duplicate_trainees ||= FindDuplicateTrainees.call(
        current_provider:,
        trainee_attributes:,
        serializer_klass:,
      )
    end

    def duplicate_trainees_response(duplicate_trainees)
      {
        json: {
          errors: "This trainee is already in Register",
          data: duplicate_trainees,
        },
        status: :conflict,
      }
    end

    def save_errors_response(trn_validator, trainee)
      validation_errors = trn_validator.all_errors.presence || trainee.errors.full_messages

      validation_error_response(validation_errors)
    end

    def success_response(trainee)
      { json: { data: serializer_klass.new(trainee).as_hash }, status: :created }
    end

    def validation_error_response(validation_errors)
      {
        json: {
          message: "Validation failed: #{validation_errors.count} #{'error'.pluralize(validation_errors.count)} prohibited this trainee from being saved",
          errors: validation_errors,
        },
        status: :unprocessable_entity,
      }
    end

    def trainee_attributes_errors
      @trainee_attributes_errors ||= begin
        trainee_attributes.validate
        trainee_attributes.errors&.full_messages&.compact&.flatten
      end
    end

    def model = :trainee
  end
end
