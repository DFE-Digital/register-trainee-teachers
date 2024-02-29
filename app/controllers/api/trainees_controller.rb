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
      trainee = current_provider.trainees.find_by!(slug: params[:slug])
      render(json: TraineeSerializer.new(trainee).as_hash)
    end

    def create
      trainee_attributes = trainee_attributes_service.new(trainee_params)

      render(
        CreateTrainee.call(current_provider:, trainee_attributes:),
      )
    end

    def update
      trainee = current_provider&.trainees&.find_by!(slug: params[:slug])
      begin
        attributes = trainee_attributes_service.from_trainee(trainee)
        attributes.assign_attributes(trainee_update_params)
        succeeded, errors = update_trainee_service_class.call(trainee:, attributes:)
        if succeeded
          render(json: { data: TraineeSerializer.new(trainee).as_hash })
        else
          render(json: { errors: }, status: :unprocessable_entity)
        end
      rescue ActionController::ParameterMissing
        render(
          json: { errors: ["Request could not be parsed"] },
          status: :unprocessable_entity,
        )
      end
    end

  private

    def trainee_params
      params.require(:data)
        .permit(
          trainee_attributes_service::ATTRIBUTES,
          placements_attributes: [placements_attributes],
          degrees_attributes: [degree_attributes_service::ATTRIBUTES],
        )
    end

    def placements_attributes
      Api::Attributes.for(model: :placement, version: version)::ATTRIBUTES
    end

    def update_trainee_service_class
      Object.const_get("Api::UpdateTraineeService::#{current_version_class_name}")
    end

    def trainee_attributes_service
      Object.const_get("Api::TraineeAttributes::#{current_version_class_name}")
    end

    def degree_attributes_service
      Api::DegreeAttributes.for(current_version)
    end

    def current_version_class_name
      current_version.gsub(".", "").camelize
    end

    def trainee_update_params
      params.require(:data).permit(trainee_attributes_service::ATTRIBUTES)
    end

    alias_method :version, :current_version
  end
end
