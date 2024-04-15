# frozen_string_literal: true

module Api
  class TraineesController < Api::BaseController
    include Api::Serializable

    def index
      trainees, errors = GetTraineesService.call(
        provider: current_provider,
        params: params,
      )

      if errors.blank?
        if trainees.exists?
          render(json: AppendMetadata.call(objects: trainees, serializer_klass: serializer_klass), status: :ok)
        else
          render_not_found(message: "No trainees found")
        end
      else
        render(
          json: {
            message: "Validation failed: #{errors.count} #{'error'.pluralize(errors.count)} prohibited this request being run",
            errors: errors,
          },
          status: :unprocessable_entity,
        )
      end
    end

    def show
      trainee = current_provider.trainees.find_by!(slug: params[:slug])
      render(json: serializer_klass.new(trainee).as_hash)
    end

    def create
      trainee_attributes = trainee_attributes_service.new(hesa_mapped_params)

      render(
        CreateTrainee.call(current_provider:, trainee_attributes:, version:),
      )
    end

    def update
      trainee = current_provider&.trainees&.find_by!(slug: params[:slug])
      begin
        attributes = trainee_attributes_service.from_trainee(trainee)
        attributes.assign_attributes(hesa_mapped_params_for_update)
        succeeded, validation = update_trainee_service_class.call(trainee:, attributes:)

        if succeeded
          render(json: { data: serializer_klass.new(trainee).as_hash })
        else
          render(
            json: {
              message: "Validation failed: #{validation.errors_count} #{'error'.pluralize(validation.errors_count)} prohibited this trainee from being saved",
              errors: validation.all_errors,
            },
            status: :unprocessable_entity,
          )
        end
      end
    end

  private

    def hesa_mapped_params
      hesa_mapper_class.call(
        params: params.require(:data).permit(
          hesa_mapper_class::ATTRIBUTES +
          trainee_attributes_service::ATTRIBUTES +
          hesa_trainee_details_attributes_service::ATTRIBUTES,
          placements_attributes: [placements_attributes],
          degrees_attributes: [degree_attributes],
          nationalisations_attributes: [nationality_attributes],
        ),
      )
    end

    def hesa_mapped_params_for_update
      hesa_mapper_class.call(
        params: params.require(:data).permit(
          hesa_mapper_class::ATTRIBUTES + trainee_attributes_service::ATTRIBUTES,
          nationalisations_attributes: [nationality_attributes],
        ),
      )
    end

    def hesa_mapper_class
      Object.const_get("Api::MapHesaAttributes::#{current_version_class_name}")
    end

    def placements_attributes
      hesa_attributes = Object.const_get("Api::MapHesaAttributes::Placements::#{current_version_class_name}")::ATTRIBUTES
      standard_attributes = Api::Attributes.for(model: :placement, version: version)::ATTRIBUTES
      standard_attributes + hesa_attributes
    end

    def nationality_attributes
      Api::Attributes.for(model: :nationality, version: version)::ATTRIBUTES
    end

    def update_trainee_service_class
      Object.const_get("Api::UpdateTraineeService::#{current_version_class_name}")
    end

    def trainee_attributes_service
      Api::Attributes.for(model: :trainee, version: version)
    end

    def hesa_trainee_details_attributes_service
      Api::Attributes.for(model: :hesa_trainee_detail, version: version)
    end

    def degree_attributes
      hesa_attributes = Object.const_get("Api::MapHesaAttributes::Degrees::#{current_version_class_name}")::ATTRIBUTES
      standard_attributes = Api::Attributes.for(model: :degree, version: version)::ATTRIBUTES
      standard_attributes + hesa_attributes
    end

    def current_version_class_name
      current_version.gsub(".", "").camelize
    end

    def trainee_update_params
      params.require(:data).permit(trainee_attributes_service::ATTRIBUTES)
    end

    def model = :trainee
  end
end
