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

    def update
      trainee = current_provider&.trainees&.find_by(slug: params[:id])
      if trainee.present?
        if update_trainee_service.call(trainee: trainee, attributes: trainee_attributes_service.new(trainee_update_params))
          render(json: TraineeSerializer.new(trainee).as_json)
        else
          # TODO: Add error messages to the response
          render(json: { error: "Trainee not updated" }, status: :unprocessable_entity)
        end
      else
        render(json: { error: "Trainee not found" }, status: :not_found)
      end
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

    def update_trainee_service
      Object.const_get("Api::UpdateTraineeService::#{current_version_class_name}")
    end

    def trainee_attributes_service
      Object.const_get("Api::TraineeAttributes::#{current_version_class_name}")
    end

    def current_version_class_name
      current_version.gsub(".", "").camelize
    end

    def trainee_update_params
      params.require(:data).permit(trainee_attributes_service::ATTRIBUTES)
    end
  end
end
