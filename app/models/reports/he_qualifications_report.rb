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
      csv_rows(qualification).each { |row| csv << row }
    end

    def csv_rows(degree)
      top_level_degree_subject = degree_subject(degree)

      degree_subjects =
        if top_level_degree_subject&.hecos_code.present?
          [top_level_degree_subject]
        elsif top_level_degree_subject&.subject_ids.present?
          top_level_degree_subject.subject_ids.map do |subject_id|
            DfEReference::DegreesQuery::SUBJECTS.one(subject_id)
          end.compact
        else
          []
        end

      degree_subjects.map do |degree_subject|
        [
          degree.trainee.trn,
          degree.trainee.date_of_birth&.iso8601,
          degree.trainee.hesa_trainee_detail&.ni_number,
          degree_subject.hecos_code,
          degree_subject.name,
        ].map { |value| CsvValueSanitiser.new(value).sanitise }
      end
    end

    def degree_subject(degree)
      DfEReference::DegreesQuery::SUBJECTS.one(degree.subject_uuid)
    end
  end
end
