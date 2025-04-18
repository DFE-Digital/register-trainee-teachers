# frozen_string_literal: true

module Api
  module Trainees
    class SavePlacementResponse
      include ServicePattern
      include Api::Attributable
      include Api::Serializable
      include Api::ErrorResponse

      def initialize(placement:, attributes:, version:)
        @placement = placement
        @placement_attributes = attributes
        @version = version
        @status = new_record? ? :created : :ok
      end

      def call
        if save
          update_progress
          { json: { data: serializer_klass.new(placement).as_hash }, status: status }
        else
          validation_errors_response(errors:)
        end
      end

      delegate :assign_attributes, :new_record?, :trainee, to: :placement
      delegate :valid?, :attributes, to: :placement_attributes

    private

      attr_reader :placement, :placement_attributes, :version, :status

      def save
        assign_attributes(attributes)

        valid? && placement.save
      end

      def model = :placement

      def errors = placement_attributes.errors.presence || placement.errors

      def update_progress
        if placement.trainee.placements.present?
          placement.trainee.progress[:placements] = true
          placement.trainee.save!
        end
      end
    end
  end
end
