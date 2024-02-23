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
        Serializer.for(model: :placement, version: current_version)
      end
    end
  end
end
