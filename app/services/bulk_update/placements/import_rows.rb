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
        bulk_placement.rows.includes(:row_errors).group_by(&:trn)
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
        return true if trainees.one?

        error_key = trainees.empty? ? :no_trainee : :multiple_trainees
        create_error_message(rows, error_key, trn:)
        false
      end

      def create_error_message(rows, error_type, variables)
        message = error_message(error_type, variables)

        rows.each do |row|
          row.failed!
          row.row_errors.create(message:)
        end
      end

      def clear_placements!(trainee)
        trainee.placements.with_school.destroy_all
      end

      def import_rows(rows)
        rows.each do |row|
          ImportRow.call(row)
        rescue StandardError => e
          row.failed!
          row.row_errors.create(message: "runtime failure: #{e.message}")
        end
      end

      def error_message(key, variables = {})
        I18n.t("activemodel.errors.models.bulk_update.placements.validate_csv_row.#{key}", **variables)
      end
    end
  end
end
