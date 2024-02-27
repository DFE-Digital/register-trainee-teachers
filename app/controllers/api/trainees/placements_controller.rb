# frozen_string_literal: true

module Api
  module Trainees
    class PlacementsController < Api::BaseController
      def index
        render(
          json: { data: trainee.placements.map { |placement| serializer_class.new(placement).as_hash } },
          status: :ok,
        )
      end

      def show
        render(json: { data: serializer_class.new(placement).as_hash }, status: :ok)
      end

      def create
        render(**PlacementResponse.call(placement: new_placement, params: placement_params, version: version))
      end

      def update
        render(**PlacementResponse.call(placement: placement, params: placement_params, version: version))
      end

      def destroy
        placement.destroy
        render({ json: { data: TraineeSerializer.new(trainee).as_hash }, status: :ok })
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

      def serializer_class
        Serializer.for(model:, version:)
      end

      def attributes_class
        Api::Attributes.for(model:, version:)
      end

      def model = :placement

      alias_method :version, :current_version

      def placement_params
        params.require(:data)
          .permit(attributes_class::ATTRIBUTES)
      end

      def new_placement
        @new_placement = trainee.placements.new
      end
    end
  end
end
