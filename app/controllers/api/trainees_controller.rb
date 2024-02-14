# frozen_string_literal: true

module Api
  class TraineesController < Api::BaseController
    def index
      trainees = GetTraineesService.call(provider: current_provider, params: params)

      if trainees.exists?
        render(json: AppendMetadata.call(trainees), status: :ok)
      else
        render_not_found(message: "No trainees found")
      end
    end

    def show
      trainee = current_provider.trainees.find_by!(slug: params[:id])
      render(json: TraineeSerializer.new(trainee).as_json)
    end

    def create
      trainee_attributes = TraineeAttributes.new(trainee_params)

      unless trainee_attributes.valid?
        render(json: { errors: trainee_attributes.errors.full_messages }, status: :unprocessable_entity)
        return
      end

      trainee = current_provider.trainees.new(trainee_attributes.deep_attributes)

      unless trainee.save
        render(json: { errors: trainee.errors.full_messages }, status: :unprocessable_entity)
        return
      end

      render(json: TraineeSerializer.new(trainee).as_json, status: :created)
    end

  private

    def trainee_params
      params.require(:data)
        .permit(
          TraineeAttributes::ATTRIBUTES,
          placements_attributes: [PlacementAttributes::ATTRIBUTES],
          degrees_attributes: [DegreeAttributes::ATTRIBUTES],
        )
    end
  end
end
