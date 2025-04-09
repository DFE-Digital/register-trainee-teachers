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

    def headers
      HEADERS
    end

    alias qualifications scope

  private

    def add_headers
      csv << headers
    end

    def add_report_rows
      qualifications.each do |qualication|
        add_qualication_to_csv(qualication)
      end
    end

    def add_qualication_to_csv(qualification)
      csv << csv_row(qualification)
    end

    def csv_row(degree)
      row = [
        degree.trainee.trn,
        degree.trainee.date_of_birth&.iso8601,
        degree.trainee.hesa_trainee_detail&.ni_number,
        degree_subject(degree)&.hecos_code,
        degree_subject(degree)&.name,
      ].map { |value| CsvValueSanitiser.new(value).sanitise }

      row
    end

    def degree_subject(degree)
      DfEReference::DegreesQuery::SUBJECTS.one(degree.subject_uuid)
    end
  end
end
