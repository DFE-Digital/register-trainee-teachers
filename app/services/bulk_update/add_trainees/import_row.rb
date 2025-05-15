# frozen_string_literal: true

module BulkUpdate
  module AddTrainees
    class ImportRow
      include ServicePattern

      CURRENT_API_VERSION = "v2025.0-rc"

      attr_accessor :row, :current_provider

      Result = Struct.new(:success, :errors, :error_type) do
        def initialize(success, errors, error_type = :validation)
          super
        end
      end

      def initialize(row:, current_provider:)
        self.row = row
        self.current_provider = current_provider
      end

      def call
        # Map the CSV header names to the correct attribute names
        attributes = BulkUpdate::AddTrainees::ImportRows::ALL_HEADERS.to_h do |header_name, attribute_name|
          [attribute_name, row[header_name]]
        end.with_indifferent_access

        attributes = prepare_csv_attributes_for_api(attributes)

        # Apply conversions to the attributes
        mapper_klass = Api::GetVersionedItem.for_service(
          model: :map_hesa_attributes,
          version: version,
        )

        trainee_attributes = trainee_attributes_service.new(mapper_klass.call(params: attributes))

        # Save the record
        json_result = Api::CreateTrainee.call(
          current_provider:,
          trainee_attributes:,
          version:,
        )

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
          Result.new(true, [], nil)
        elsif json_result[:status] == :conflict
          Result.new(false, ["This trainee is already in Register"], :duplicate)
        else
          Result.new(false, json_result.dig(:json, :errors), :validation)
        end
      end

      def prepare_csv_attributes_for_api(attributes)
        attributes[:lead_partner_not_applicable] = attributes[:lead_partner_urn].blank?
        prepare_degree_attributes(attributes)
        prepare_placement_attributes(attributes)
        prepare_record_source_attribute(attributes)
        attributes
      end

      def prepare_degree_attributes(attributes)
        attributes[:degrees_attributes] = [
          attributes.slice(
            :grade,
            :subject,
            :institution,
            :uk_degree,
            :graduation_year,
            :non_uk_degree,
            :country,
          ).compact
        ].compact_blank
      end

      def prepare_placement_attributes(attributes)
        attributes.slice(
          :placement_urn1,
          :placement_urn2,
          :placement_urn3,
        ).compact.each_with_index do |(_placement, urn), index|
          (attributes[:placements_attributes] ||= []) << {
            name: "Placement #{index + 1}",
            urn: urn,
          }
        end
      end

      def prepare_record_source_attribute(attributes)
        return attributes if attributes[:record_source].present?

        attributes[:record_source] = Trainee::CSV_SOURCE
      end
    end
  end
end
