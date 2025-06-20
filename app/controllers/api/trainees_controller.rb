# frozen_string_literal: true

module Api
  class TraineesController < Api::BaseController
    include Api::Serializable

    def index
      trainees, errors = GetTraineesService.call(
        provider: current_provider,
        params: params,
        version: version,
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
      if trainee.hesa_trainee_detail.nil?
        create_hesa_trainee_detail_service_class.call(trainee:)
        trainee.reload
      end

      attributes = trainee_attributes_service.from_trainee(trainee, hesa_mapped_params_for_update)

      succeeded, validation = update_trainee_service_class.call(trainee:, attributes:)

      if succeeded
        render(json: { data: serializer_klass.new(trainee).as_hash })
      else
        render(
          json: {
            message: "Validation failed: #{validation.all_errors.count} #{'error'.pluralize(validation.all_errors.count)} prohibited this trainee from being saved",
            errors: validation.all_errors,
          },
          status: :unprocessable_entity,
        )
      end
    end

  private

    def hesa_mapped_params
      hesa_mapper_class.call(
        params: params.require(:data).permit(
          hesa_mapper_class::ATTRIBUTES + hesa_mapper_class.disability_attributes(params),
          trainee_attributes_service::ATTRIBUTES.keys + hesa_trainee_details_attributes_service::ATTRIBUTES,
          placements_attributes: placements_attributes,
          degrees_attributes: degree_attributes,
          nationalisations_attributes: nationality_attributes,
        ),
      )
    end

    def hesa_mapped_params_for_update
      hesa_mapper_class.call(
        params: params.require(:data).permit(
          hesa_mapper_class::ATTRIBUTES +
          trainee_attributes_service::ATTRIBUTES.keys,
          hesa_mapper_class.disability_attributes(params),
          hesa_trainee_details_attributes_service::ATTRIBUTES,
        ), update: true
      )
    end

    def hesa_mapper_class
      Api::GetVersionedItem.for_service(model: :map_hesa_attributes, version: version)
    end

    def placements_attributes
      @placements_attributes ||= begin
        hesa_attributes = Api::GetVersionedItem.for_service(model: :placement, version: version)::ATTRIBUTES
        standard_attributes = Api::GetVersionedItem.for_attributes(model: :placement, version: version)::ATTRIBUTES
        standard_attributes + hesa_attributes
      end
    end

    def nationality_attributes
      Api::GetVersionedItem.for_attributes(model: :nationality, version: version)::ATTRIBUTES
    end

    def create_hesa_trainee_detail_service_class
      Api::GetVersionedItem.for_service(model: :create_hesa_trainee_detail, version: version)
    end

    def update_trainee_service_class
      Api::GetVersionedItem.for_service(model: :update_trainee, version: version)
    end

    def trainee_attributes_service
      Api::GetVersionedItem.for_attributes(model: :trainee, version: version)
    end

    def hesa_trainee_details_attributes_service
      Api::GetVersionedItem.for_attributes(model: :hesa_trainee_detail, version: version)
    end

    def degree_attributes
      @degree_attributes ||= begin
        hesa_attributes = Api::GetVersionedItem.for_service(model: :degree, version: version)::ATTRIBUTES
        standard_attributes = Api::GetVersionedItem.for_attributes(model: :degree, version: version)::ATTRIBUTES
        standard_attributes + hesa_attributes
      end
    end

    def model = :trainee
  end
end
