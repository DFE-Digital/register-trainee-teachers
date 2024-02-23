# frozen_string_literal: true

module Api
  class CreateTrainee
    include ServicePattern

    attr_accessor :current_provider, :trainee_attributes

    def initialize(current_provider:, trainee_attributes:)
      @current_provider = current_provider
      @trainee_attributes = trainee_attributes
    end

    def call
      return validation_error_response(trainee_attributes) unless trainee_attributes.valid?

      return duplicate_trainees_response(duplicate_trainees) if duplicate_trainees.present?

      trainee = current_provider.trainees.new(trainee_attributes.deep_attributes)
      unless trainee.save
        return save_errors_response(trainee)
      end

      success_response(trainee)
    end

  private

    def duplicate_trainees
      @duplicate_trainees ||= FindDuplicateTrainees.call(
        current_provider:,
        trainee_attributes:,
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

    def save_errors_response(trainee)
      { json: { errors: trainee.errors.full_messages }, status: :unprocessable_entity }
    end

    def success_response(trainee)
      { json: TraineeSerializer.new(trainee).as_hash, status: :created }
    end

    def validation_error_response(trainee_attributes)
      {
        json: { errors: trainee_attributes.errors.full_messages },
        status: :unprocessable_entity,
      }
    end
  end
end
