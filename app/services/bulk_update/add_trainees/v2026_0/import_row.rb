# frozen_string_literal: true

module BulkUpdate
  module AddTrainees
    module V20260
      class ImportRow
        include ServicePattern

        attr_accessor :row, :current_provider

        Result = Struct.new(:slug, :success, :errors, :error_type) do
          def initialize(slug, success, errors, error_type = :validation)
            super
          end
        end

        def initialize(row:, current_provider:)
          self.row = remove_leading_apostrophes(row)
          self.current_provider = current_provider
        end

        def call
          # Map the CSV header names to the correct attribute names
          attributes = V20260::ImportRows::ALL_HEADERS.to_h do |header_name, attribute_name|
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
            current_provider: current_provider,
            trainee_attributes: trainee_attributes,
            version: version,
            submit_for_trn: false,
          )

          json_result_to_result(json_result)
        end

      private

        def version
          BulkUpdate::AddTrainees::Config::VERSION
        end

        def trainee_attributes_service
          Api::GetVersionedItem.for_attributes(model: :trainee, version: version)
        end

        def json_result_to_result(json_result)
          if json_result[:status] == :created
            Result.new(json_result.dig(:json, :data, :trainee_id), true, [], nil)
          elsif json_result[:status] == :conflict
            Result.new(nil, false, ["This trainee is already in Register"], :duplicate)
          else
            Result.new(nil, false, json_result.dig(:json, :errors), :validation)
          end
        end

        def prepare_csv_attributes_for_api(attributes)
          attributes.transform_values!(&:presence)
          attributes[:training_partner_not_applicable] = attributes[training_partner_urn_attribute].blank?
          prepare_degree_attributes(attributes)
          prepare_placement_attributes(attributes)
          prepare_record_source_attribute(attributes)
          attributes
        end

        def training_partner_urn_attribute
          V20260::ImportRows::ALL_HEADERS["Training Partner URN"].to_sym
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
            ).compact,
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

        def remove_leading_apostrophes(row)
          row.to_h.transform_values do |value|
            value.is_a?(String) && value.start_with?("'") ? value[1..] : value
          end
        end
      end
    end
  end
end
