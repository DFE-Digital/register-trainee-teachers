# frozen_string_literal: true

module Api
  module Trainees
    class DegreesController < Api::BaseController
      def index
        trainee = current_provider.trainees.find_by!(slug: params[:trainee_slug])

        render(
          json: { data: trainee.degrees.map { |degree| degree_serializer_class.new(degree).as_hash } },
          status: :ok,
        )
      end

      def create
        trainee = current_provider.trainees.find_by!(slug: params[:trainee_slug])
        degree_attributes = degree_attributes_service.new(degree_params)

        render(
          Api::CreateDegree.call(trainee:, degree_attributes:, current_version:),
        )
      end

      def update
        trainee = current_provider.trainees.find_by!(slug: params[:trainee_slug])
        degree = trainee.degrees.find_by!(slug: params[:slug])

        begin
          attributes = degree_attributes_service.from_degree(degree)
          attributes.assign_attributes(degree_update_params)
          succeeded, errors = update_degree_service_class.call(degree:, attributes:)
          if succeeded
            render(json: { data: degree_serializer_class.new(degree).as_hash })
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

      def destroy
        trainee = current_provider.trainees.find_by!(slug: params[:trainee_slug])
        degree = trainee.degrees.find_by!(slug: params[:slug])

        if degree.destroy
          render(json: { data: degree_serializer_class.new(degree).as_hash })
        else
          render(json: { errors: degree.errors.full_messages }, status: :unprocessable_entity)
        end
      end

    private

      def degree_params
        params.require(:data)
          .permit(degree_attributes_service::ATTRIBUTES)
      end

      alias_method :degree_update_params, :degree_params

      def update_degree_service_class
        Api::UpdateDegreeService.for(current_version)
      end

      def degree_serializer_class
        DegreeSerializer.for(current_version)
      end

      def degree_attributes_service
        Api::DegreeAttributes.for(current_version)
      end
    end
  end
end