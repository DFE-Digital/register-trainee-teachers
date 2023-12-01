# frozen_string_literal: true

module BulkUpdate
  module Placements
    class ValidateCsvRow
      include Config

      def initialize(csv:, row:)
        @csv = csv
        @row = row
        @error_messages = []
        @urns = []

        validate!
      end

      def valid?
        error_messages.empty?
      end

      attr_reader :error_messages, :urns

    private

      attr_reader :csv, :row

      def validate!
        return if row.empty?

        trn_format
        validate_duplicate_placements
        validate_placements if unique?(placement_urns)
      end

      def trn_format
        return if row.trn =~ VALID_TRN

        @error_messages << error_message(:trn_format)
      end

      def validate_duplicate_placements
        return if unique?(placement_urns)

        @error_messages << error_message(:duplicate_urns)
      end

      def placement_urns
        @placement_urns ||= MAX_PLACEMENTS.times.map do |i|
          number = i + 1
          row.send("placement_#{number}_urn").presence
        end.compact
      end

      def validate_placements
        placement_urns.each_with_index do |urn, i|
          validate_placement(urn, i + 1)
        end
      end

      def validate_placement(urn, number)
        case urn
        when VALID_URN
          placements << (School.find_by(urn:) || error_message(:school_not_found, { urn:, number: }))
        else
          error_messages << error_message(:urn_format, { number: })
        end
      end

      def unique?(array)
        array.uniq.length == array.length
      end

      def error_message(key, variables = {})
        I18n.t("activemodel.errors.models.bulk_update.placements.validate_csv_row.#{key}", **variables)
      end
    end
  end
end
