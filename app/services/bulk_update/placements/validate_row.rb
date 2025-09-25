# frozen_string_literal: true

module BulkUpdate
  module Placements
    class ValidateRow
      def initialize(placement_row)
        @urn = placement_row.urn
        @error_messages = []
        validate!
      end

      def valid?
        error_messages.empty?
      end

      def school
        return @school if defined?(@school)

        @school = School.find_by(urn:)
      end

      attr_reader :error_messages

    private

      attr_reader :urn

      def validate!
        validate_urn_format
        validate_school
      end

      def validate_urn_format
        return if urn =~ Config::VALID_URN

        @error_messages << error_message(:urn_format)
      end

      def validate_school
        return if school

        @error_messages << error_message(:no_school, urn:)
      end

      def error_message(key, variables = {})
        I18n.t("activemodel.errors.models.bulk_update.placements.validate_csv_row.#{key}", **variables)
      end
    end
  end
end
