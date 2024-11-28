# frozen_string_literal: true

module Reports
  class BulkTraineeUploadReport < TemplateClassCsv
    HEADERS = (BulkUpdate::AddTrainees::ImportRows::TRAINEE_HEADERS.keys + ["Errors"]).freeze

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

    def add_row_to_csv(row)
      data = row.data.merge(
        "Errors" => row.row_errors.pluck(:message).join(", "),
      )
      csv << (HEADERS.map do |key|
        CsvValueSanitiser.new(data[key]).sanitise
      end)
    end
  end
end
