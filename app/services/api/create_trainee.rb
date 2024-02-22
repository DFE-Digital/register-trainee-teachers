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
      unless trainee_attributes.valid?
        return {
          json: { errors: trainee_attributes.errors.full_messages },
          status: :unprocessable_entity,
        }
      end

      duplicate_trainees = Api::FindDuplicateTrainees.call(
        current_provider:,
        trainee_attributes:,
      )
      if duplicate_trainees.present?
        return {
          json: {
            errors: "This trainee is already in Register",
            data: duplicate_trainees,
          },
          status: :conflict,
        }
      end

      trainee = current_provider.trainees.new(trainee_attributes.deep_attributes)
      unless trainee.save
        return { json: { errors: trainee.errors.full_messages }, status: :unprocessable_entity }
      end

      { json: TraineeSerializer.new(trainee).as_hash, status: :created }
    end
  end
end
