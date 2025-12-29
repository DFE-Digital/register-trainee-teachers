# frozen_string_literal: true

module Api
  module Trainees
    class PlacementsController < Api::BaseController
      include Api::Serializable
      include Api::Attributable

      def index
        render(
          json: { data: trainee.placements.includes([:school]).map { |placement| serializer_klass.new(placement).as_hash } },
          status: :ok,
        )
      end

      def show
        render(json: { data: serializer_klass.new(placement).as_hash }, status: :ok)
      end

      def create
        placement_attributes = attributes_klass.new(hesa_mapped_params)
        render(**SavePlacementResponse.call(placement: new_placement, attributes: placement_attributes, version: version))
      end

      def update
        placement_attributes = attributes_klass.from_placement(placement)
        placement_attributes.assign_attributes(placement_params.to_h)
        render(**SavePlacementResponse.call(placement: placement, attributes: placement_attributes, version: version))
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
        @placement ||= trainee.placements.includes([:school]).find_by!(slug:)
      end

      def slug = params[:placement_slug]

      def trainee_serializer_klass
        Api::GetVersionedItem.for_serializer(model: :trainee, version: version)
      end

      def model = :placement

      def hesa_mapper_class
        Api::GetVersionedItem.for_service(model: :map_hesa_attributes, version: version)
      end

      def hesa_mapped_params
        hesa_mapper_class.call(
          params: params.expect(
            data: [hesa_mapper_class::ATTRIBUTES, attributes_klass::ATTRIBUTES],
          ),
        )
      end

      def placement_params
        params.expect(data: attributes_klass::ATTRIBUTES)
      end

      def new_placement
        @new_placement = trainee.placements.new
      end
    end
  end
end
