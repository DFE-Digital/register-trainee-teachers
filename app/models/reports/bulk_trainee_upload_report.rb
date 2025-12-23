# frozen_string_literal: true

module Reports
  class BulkTraineeUploadReport < TemplateClassCsv
    include ActionView::Helpers::TextHelper

    def initialize(csv, scope:)
      @csv = csv
      @scope = scope
    end

    alias trainee_upload scope

  private

    def headers
      @headers ||= BulkUpdate::AddTrainees::VERSION::ImportRows::ALL_HEADERS.keys + ["Validation results", "Errors"]
    end

    def add_headers
      csv << headers
    end

    def add_report_rows
      trainee_upload.trainee_upload_rows.each do |row|
        add_row_to_csv(row)
      end
    end

    def add_row_to_csv(row)
      data = row.data.merge(
        "Validation results" => row.row_errors.present? ? "#{pluralize(row.row_errors.size, 'error')} found" : "Validation passed",
        "Errors" => row.row_errors.pluck(:message).join(";\n").presence,
      )

      csv << (headers.map do |key|
        AddTraineeCsvValueSanitiser.new(key, data[key]).sanitise
      end)
    end
  end
end
