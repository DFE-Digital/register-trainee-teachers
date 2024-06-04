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
            params: degree_params,
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
        params.require(:data)
          .permit(attributes_klass::ATTRIBUTES)
      end

      def trainee
        @trainee ||= current_provider.trainees.find_by!(slug: params[:trainee_slug])
      end

      def degree
        @degree ||= trainee.degrees.find_by!(slug: params[:slug])
      end

      def trainee_serializer_klass
        Api::GetVersionedItem.for_serializer(model: :trainee, version: version)
      end

      def new_degree
        @new_degree ||= trainee.degrees.new
      end

      def model = :degree

      alias_method :degree_update_params, :degree_params
    end
  end
end
