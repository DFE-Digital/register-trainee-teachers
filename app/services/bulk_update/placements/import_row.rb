# frozen_string_literal: true

module BulkUpdate
  module Placements
    class ImportRow
      include ServicePattern

      def initialize(placement_row)
        @placement_row = placement_row
      end

      def call
        return unless placement_row.can_be_imported?

        placement_row.error_messages.destroy_all
        placement_row.importing!

        if validator.valid?
          create_placement!
        else
          record_errors!
        end
      end

    private

      attr_reader :placement_row

      def create_placement!
        row.update(school: school, state: :imported)
        Placement.find_or_create_by(trainee:, school:, urn:)
      end

      def record_errors!
        validator.error_messages.each do |message|
          row.error_message.create(message:)
        end
        row.failed!
      end

      def school
        @school ||= validator.school
      end

      def trainee
        @trainee ||= Trainee.find_by_trn(placement_row.trn)
      end

      def validator
        @validator ||= ValidateRow.call(placement_row)
      end
    end
  end
end
