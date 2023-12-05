# frozen_string_literal: true

module BulkUpdate
  module Placements
    class ImportRows
      include ServicePattern

      def initialize(bulk_placement)
        @bulk_placement = bulk_placement
        @provider = bulk_placement.provider
      end

      def call
        grouped_rows_by_trn.each do |trn, rows|
          handle_trainee_rows(trn, rows)
        end
      end

    private

      attr_reader :bulk_placement, :provider

      def grouped_rows_by_trn
        bulk_placement.rows.group_by(&:trn)
      end

      def handle_trainee_rows(trn, rows)
        trainees = find_trainees(trn)
        return unless valid_trainee?(trainees, trn, rows)

        clear_placements!(trainees.first)
        import_rows(rows)
      end

      def find_trainees(trn)
        provider.trainees.where(trn:)
      end

      def valid_trainee?(trainees, trn, rows)
        case trainees.count
        when 0
          create_error_message(rows, :no_trainee, trn:)
          false
        when 1
          true
        else
          create_error_message(rows, :multiple_trainees, trn:)
          false
        end
      end

      def create_error_message(rows, error_type, variables)
        message = error_message(error_type, variables)

        rows.each do |row|
          row.failed!
          row.error_message.create(message:)
        end
      end

      def import_rows(rows)
        rows.each do |row|
          ImportRowJob.perform_later(row)
        end
      end

      def clear_placements!(trainee)
        trainee.placements_with_urn.destroy_all
      end

      def error_message(key, variables = {})
        I18n.t("activemodel.errors.models.bulk_update.placements.validate_csv_row.#{key}", **variables)
      end
    end
  end
end
