# frozen_string_literal: true

module Api
  module Trainees
    class SavePlacementResponse
      include ServicePattern
      include Api::ErrorResponse

      def initialize(placement:, params:, version:)
        @placement = placement
        @params = params
        @version = version
        @status = new_record? ? :created : :ok
      end

      def call
        if save
          update_progress
          { json: { data: serializer_class.new(placement).as_hash }, status: status }
        elsif duplicate?
          conflict_errors_response(errors:)
        else
          validation_errors_response(errors:)
        end
      end

      delegate :assign_attributes, :new_record?, to: :placement
      delegate :valid?, :attributes, to: :placement_attributes

    private

      attr_reader :placement, :params, :version, :status

      def save
        assign_attributes(attributes)

        if valid? && placement.save
          true
        else
          false
        end
      end

      def serializer_class
        Serializer.for(model:, version:)
      end

      def attributes_class
        Api::Attributes.for(model:, version:)
      end

      def model = :placement

      def placement_attributes
        @placement_attributes ||= attributes_class.new(params)
      end

      def errors = placement_attributes.errors.presence || placement.errors

      def duplicate?
        placement.errors.details.values.flatten.any? { |error| error[:error] == :taken }
      end

      def update_progress
        if placement.trainee.placements.present?
          placement.trainee.progress[:placements] = true
          placement.trainee.save!
        end
      end
    end
  end
end
