# frozen_string_literal: true

module Reports
  class HeQualificationsReport < TemplateClassCsv
    # headers
    TRN = "trn"
    DATE_OF_BIRTH = "date_of_birth"
    NINO = "nino"
    SUBJECT_CODE = "subject_code"
    DESCRIPTION = "description"

    HEADERS = [TRN, DATE_OF_BIRTH, NINO, SUBJECT_CODE, DESCRIPTION].freeze

    def initialize(csv, scope:)
      @csv = csv
      @scope = scope
    end

    def headers
      HEADERS
    end

    alias trainees scope

  private

    def add_headers
      csv << headers
    end

    def add_report_rows
      trainees.strict_loading.includes(:hesa_trainee_detail).find_each do |trainee|
        add_trainee_to_csv(trainee)
      end
    end

    def add_trainee_to_csv(trainee)
      csv << csv_row(trainee)
    end

    def csv_row(trainee)
      report = Reports::TraineeReport.new(trainee)

      row = [
        report.trn,
        report.date_of_birth,
        report.ni_number,
        report.subject_code,
        report.description,
      ].map { |value| CsvValueSanitiser.new(value).sanitise }

      row
    end
  end
end
