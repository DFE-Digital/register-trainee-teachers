# frozen_string_literal: true

module BulkUpdate
  module Placements
    class ImportRow
      include ServicePattern

      def initialize(placement_row)
        @placement_row = placement_row
        @urn           = placement_row.urn
      end

      def call
        return unless placement_row.can_be_imported?

        placement_row.row_errors.destroy_all
        placement_row.importing!

        if validator.valid?
          create_placement
        else
          record_errors
        end
      end

    private

      attr_reader :placement_row, :urn

      def create_placement
        placement_row.update(school: school, state: :imported)

        ::Placement.create(trainee:, school:)
      end

      def record_errors
        validator.error_messages.each do |message|
          placement_row.row_errors.create(message:)
        end
        placement_row.failed!
      end

      def school
        @school ||= validator.school
      end

      def provider
        placement_row.bulk_update_placement.provider
      end

      def trainee
        @trainee ||= provider.trainees.find_by_trn(placement_row.trn)
      end

      def validator
        @validator ||= ValidateRow.new(placement_row)
      end
    end
  end
end
