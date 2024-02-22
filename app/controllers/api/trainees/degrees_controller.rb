# frozen_string_literal: true

module Api
  module Trainees
    class DegreesController < Api::BaseController
      def index
        trainee = current_provider.trainees.find_by!(slug: params[:trainee_slug])
        trainee.degrees

        render(
          json: { data: trainee.degrees.map { |degree| DegreeSerializer.for(current_version).new(degree).as_hash } },
          status: :ok,
        )
      end

      def create
        trainee = current_provider.trainees.find_by!(slug: params[:trainee_slug])

        # TODO: Refactor this into a service?
        degree_attributes = Api::DegreeAttributes.for(current_version).new(degree_params)
        unless degree_attributes.valid?
          render(json: { errors: degree_attributes.errors.full_messages }, status: :unprocessable_entity)
          return
        end

        new_degree = trainee.degrees.new(degree_attributes.attributes)

        # TODO: Duplicate matching?

        unless new_degree.save
          render(json: { errors: new_degree.errors.full_messages }, status: :unprocessable_entity)
          return
        end

        render(
          json: { data: DegreeSerializer.for(current_version).new(new_degree).as_hash },
          status: :created,
        )
      end

    private

      def degree_params
        params.require(:data)
          .permit(Api::DegreeAttributes.for(current_version)::ATTRIBUTES)
      end
    end
  end
end
