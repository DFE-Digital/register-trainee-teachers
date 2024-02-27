# frozen_string_literal: true

module Api
  module Trainees
    class PlacementResponse
      include ServicePattern
      include Api::ErrorResponse

      def initialize(placement:, params:, version:)
        @placement = placement
        @params = params
        @version = version
        @status = new_record? ? :created : :ok
      end

      def call
        if save!
          { json: { data: serializer_class.new(placement).as_hash }, status: status }
        else
          validation_errors_response(errors:)
        end
      end

      delegate :assign_attributes, :save, :new_record?, to: :placement
      delegate :valid?, :attributes, to: :placement_attributes

    private

      attr_reader :placement, :params, :version, :status

      def save!
        assign_attributes(attributes)

        if valid? && save
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

      def errors = placement_attributes.errors || placement.errors
    end
  end
end
