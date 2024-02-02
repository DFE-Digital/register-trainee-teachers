# frozen_string_literal: true

module Api
  class TraineesController < Api::BaseController
    def show
      trainee = current_provider&.trainees&.find_by(slug: params[:id])
      if trainee.present?
        render(json: TraineeSerializer.new(trainee).as_json)
      else
        render(json: { error: "Trainee not found" }, status: :not_found)
      end
    end

    def create
      trainee_attributes = TraineeAttributes.new(trainee_params)

      unless trainee_attributes.valid?
        render json: { errors: trainee_attributes.errors.full_messages }, status: :unprocessable_entity
        return
      end

      trainee = Trainee.new(trainee_attributes.to_h)

      unless trainee.save
        render json: { errors: trainee.errors.full_messages }, status: :unprocessable_entity
        return
      end

      render json: TraineeSerializer.new(trainee).as_json, status: :ok
    end

    private

    def trainee_params
      params.require(:trainee)
        .permit(
          TraineeAttributes::ATTRIBUTES,
          placements_attributes: PlacementAttributes::ATTRIBUTES,
          degrees_attributes: DegreeAttributes::ATTRIBUTES
        )
    end
  end
end
