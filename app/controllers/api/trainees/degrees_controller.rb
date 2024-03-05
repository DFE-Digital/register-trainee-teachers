# frozen_string_literal: true

module Api
  module Trainees
    class DegreesController < Api::BaseController
      def index
        trainee = current_provider.trainees.find_by!(slug: params[:trainee_slug])

        render(
          json: { data: trainee.degrees.map { |degree| serializer_class.new(degree).as_hash } },
          status: :ok,
        )
      end

      def create
        render(
          **SaveDegreeResponse.call(
            degree: new_degree,
            params: degree_params,
            version: current_version,
          ),
        )
      end

      def update
        render(
          **SaveDegreeResponse.call(
            degree: degree,
            params: degree_params,
            version: current_version,
          ),
        )
      end

      def destroy
        if degree.destroy
          render(json: { data: serializer_class.new(degree).as_hash })
        else
          render(json: { errors: degree.errors.full_messages }, status: :unprocessable_entity)
        end
      end

    private

      def degree_params
        params.require(:data)
          .permit(attributes_class::ATTRIBUTES)
      end

      def trainee
        @trainee ||= current_provider.trainees.find_by!(slug: params[:trainee_slug])
      end

      def degree
        @degree ||= trainee.degrees.find_by!(slug: params[:slug])
      end

      def serializer_class
        Serializer.for(model:, version:)
      end

      def attributes_class
        Api::Attributes.for(model:, version:)
      end

      def new_degree
        @new_degree ||= trainee.degrees.new
      end

      def model = :degree

      alias_method :version, :current_version
      alias_method :degree_update_params, :degree_params
    end
  end
end
