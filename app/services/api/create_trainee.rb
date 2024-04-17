# frozen_string_literal: true

module Api
  class CreateTrainee
    include ServicePattern
    include Serializable

    attr_accessor :current_provider, :trainee_attributes, :version

    def initialize(current_provider:, trainee_attributes:, version:)
      @current_provider = current_provider
      @trainee_attributes = trainee_attributes
      @version = version
    end

    def call
      return validation_error_response if validation_errors.any?

      return duplicate_trainees_response(duplicate_trainees) if duplicate_trainees.present?

      if trainee.save && validation.all_errors.empty?
        ::Trainees::SubmitForTrn.call(trainee:)
        success_response(trainee)
      else
        save_errors_response(validation)
      end
    end

  private

    def trainee
      @trainee ||= current_provider.trainees.build(trainee_attributes.deep_attributes)
    end

    def validation
      Submissions::ApiTrnValidator.new(trainee:)
    end

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

    def save_errors_response(validation)
      {
        json: {
          message: "Validation failed: #{validation.errors_count} #{'error'.pluralize(validation.errors_count)} prohibited this user from being saved",
          errors: validation.all_errors,
        },
        status: :unprocessable_entity,
      }
    end

    def success_response(trainee)
      { json: serializer_klass.new(trainee).as_hash, status: :created }
    end

    def validation_error_response
      {
        json: { errors: validation_errors },
        status: :unprocessable_entity,
      }
    end

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

    def model = :trainee
  end
end
