# frozen_string_literal: true

module Api
  module Trainees
    class DegreesController < Api::BaseController
      include Api::Attributable
      include Api::Serializable

      def index
        trainee = current_provider.trainees.find_by!(slug: params[:trainee_slug])

        render(
          json: { data: trainee.degrees.map { |degree| serializer_klass.new(degree).as_hash } },
          status: :ok,
        )
      end

      def show
        render(json: { data: serializer_klass.new(degree).as_hash }, status: :ok)
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
            params: degree_params_for_update,
            version: current_version,
          ),
        )
      end

      def destroy
        if degree.destroy
          render(json: { data: trainee_serializer_klass.new(trainee).as_hash })
        else
          render(json: { errors: degree.errors.full_messages }, status: :unprocessable_entity)
        end
      end

    private

      def degree_params
        hesa_mapper_class.call(
          params.require(:data).permit(
            hesa_mapper_class::ATTRIBUTES,
          ),
        )
      end

      def degree_params_for_update
        hesa_mapper_class.call(
          params.require(:data).permit(
            hesa_mapper_class::ATTRIBUTES,
          ),
        ).slice(*map_param_keys_for_update)
      end

      def map_param_keys_for_update
        param_keys = params[:data].keys.map(&:to_sym)

        if param_keys.include?(:uk_degree) || param_keys.include?(:non_uk_degree)
          param_keys << :locale_code
          param_keys << :uk_degree
          param_keys << :uk_degree_uuid
          param_keys << :non_uk_degree
          param_keys << :country
        end

        param_keys.uniq
      end

      def hesa_mapper_class
        Api::GetVersionedItem.for_service(model: :degree, version: version)
      end

      def trainee
        @trainee ||= current_provider.trainees.find_by!(slug: params[:trainee_slug])
      end

      def degree
        @degree ||= trainee.degrees.find_by!(slug: params[:degree_slug])
      end

      def trainee_serializer_klass
        Api::GetVersionedItem.for_serializer(model: :trainee, version: version)
      end

      def new_degree
        @new_degree ||= trainee.degrees.new
      end

      def model = :degree
    end
  end
end
