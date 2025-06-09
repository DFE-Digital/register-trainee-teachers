# frozen_string_literal: true

module Reports
  class BulkTraineeUploadReport < TemplateClassCsv
    include ActionView::Helpers::TextHelper

    HEADERS = (BulkUpdate::AddTrainees::ImportRows::ALL_HEADERS.keys + ["Validation results", "Errors"]).freeze

    def initialize(csv, scope:)
      @csv = csv
      @scope = scope
    end

    alias trainee_upload scope

  private

    def add_headers
      csv << HEADERS
    end

    def add_report_rows
      trainee_upload.trainee_upload_rows.each do |row|
        add_row_to_csv(row)
      end
    end

    class AddTraineeCsvValueSanitiser < CsvValueSanitiser
      def initialize(key, value)
        @key = key
        super(value)
      end

      def safe?
        super &&
          (!@key.in?(BulkUpdate::AddTrainees::ImportRows::PREFIXED_HEADERS) ||
          @value.blank? ||
          @value.start_with?("'"))
      end

      def wrap_in_double_quotes(value)
        value
      end
    end

    def add_row_to_csv(row)
      data = row.data.merge(
        "Validation results" => row.row_errors.present? ? "#{pluralize(row.row_errors.size, 'error')} found" : "Validation passed",
        "Errors" => row.row_errors.pluck(:message).join(";\n").presence,
      )
      csv << (HEADERS.map do |key|
        AddTraineeCsvValueSanitiser.new(key, data[key]).sanitise
      end)
    end
  end
end
