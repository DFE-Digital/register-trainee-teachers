# frozen_string_literal: true

module Api
  module Trainees
    class SaveDegreeResponse
      include ServicePattern
      include Api::ErrorResponse

      def initialize(degree:, params:, version:)
        @degree = degree
        @params = params
        @version = version
        @status = new_record? ? :created : :ok
      end

      def call
        if save
          { json: { data: serializer_class.new(degree).as_hash }, status: status }
        else
          validation_errors_response(errors:)
        end
      end

      delegate :assign_attributes, :new_record?, to: :degree
      delegate :valid?, :attributes, to: :degree_attributes

    private

      attr_reader :degree, :params, :version, :status

      def save
        assign_attributes(attributes)

        if valid? && degree.save
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

      def model = :degree

      def degree_attributes
        @degree_attributes ||=
          if new_record?
            attributes_class.new(params)
          else
            attributes = attributes_class.from_degree(degree)
            attributes.assign_attributes(params)
            attributes
          end
      end

      def errors = degree_attributes.errors || degree.errors
    end
  end
end
