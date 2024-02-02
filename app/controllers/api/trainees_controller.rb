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

      if trainee_attributes.valid?
        trainee = Trainee.new(trainee_attributes.to_h)

        if trainee.save
          render json: Api::TraineeSerializer.new(trainee).as_json, status: :ok
        else
          render json: { errors: trainee.errors.full_messages }, status: :unprocessable_entity
        end
      else
        render json: { errors: trainee_attributes.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def trainee_params
      params.require(:trainee).permit(TraineeAttributes::ATTRIBUTES)
    end

  end
end
