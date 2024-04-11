# frozen_string_literal: true

module Api
  module Trainees
    class PlacementsController < Api::BaseController
      include Api::Serializable
      include Api::Attributable

      def index
        render(
          json: { data: trainee.placements.map { |placement| serializer_klass.new(placement).as_hash } },
          status: :ok,
        )
      end

      def show
        render(json: { data: serializer_klass.new(placement).as_hash }, status: :ok)
      end

      def create
        render(**SavePlacementResponse.call(placement: new_placement, params: placement_params, version: version))
      end

      def update
        render(**SavePlacementResponse.call(placement: placement, params: placement_params, version: version))
      end

      def destroy
        placement.destroy
        render({ json: { data: trainee_serializer_klass.new(trainee).as_hash }, status: :ok })
      end

    private

      def trainee
        @trainee ||= current_provider.trainees.find_by!(slug: trainee_slug)
      end

      def trainee_slug = params[:trainee_slug]

      def placement
        @placement ||= trainee.placements.find_by!(slug:)
      end

      def slug = params[:slug]

      def trainee_serializer_klass
        Serializer.for(model: :trainee, version: version)
      end

      def model = :placement

      def placement_params
        params.require(:data)
          .permit(attributes_klass::ATTRIBUTES)
      end

      def new_placement
        @new_placement = trainee.placements.new
      end
    end
  end
end
