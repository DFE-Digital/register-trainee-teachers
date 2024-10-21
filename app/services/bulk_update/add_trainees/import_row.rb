# frozen_string_literal: true

module BulkUpdate
  module AddTrainees
    class ImportRow
      include ServicePattern

      CURRENT_API_VERSION = "v1.0-pre"

      attr_accessor :row, :current_provider

      Result = Struct.new(:success, :errors)

      def initialize(row:, current_provider:)
        self.row = row
        self.current_provider = current_provider
      end

      def call
        # Map the CSV header names to the correct attribute names
        attributes = BulkUpdate::AddTrainees::ImportRows::TRAINEE_HEADERS.map do |header_name, attribute_name|
          [attribute_name, row[header_name]]
        end.to_h.with_indifferent_access

        # Apply conversions to the attributes
        mapper_klass = Api::GetVersionedItem.for_service(model: :map_hesa_attributes, version:)
        trainee_attributes = trainee_attributes_service.new(mapper_klass.call(params: attributes))

        # Save the record
        json_result = Api::CreateTrainee.call(current_provider:, trainee_attributes:, version:)

        json_result_to_result(json_result)
      end

    private

      def version
        CURRENT_API_VERSION
      end

      def trainee_attributes_service
        Api::GetVersionedItem.for_attributes(model: :trainee, version: version)
      end

      def json_result_to_result(json_result)
        if json_result[:status] == :created
          Result.new(true, [])
        else
          Result.new(false, json_result.fetch(:json, :errors))
        end
      end
    end
  end
end
