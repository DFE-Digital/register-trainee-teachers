# frozen_string_literal: true

module Reports
  class ClaimsDegreeReport < TemplateClassCsv
    TRN = "trn"
    DATE_OF_BIRTH = "date_of_birth"
    NINO = "nino"
    SUBJECT_CODE = "subject_code"
    DESCRIPTION = "description"

    HEADERS = [TRN, DATE_OF_BIRTH, NINO, SUBJECT_CODE, DESCRIPTION].freeze

    def headers
      HEADERS
    end

    alias degrees scope

  private

    def add_headers
      csv << headers
    end

    def add_report_rows
      degrees.each do |degree|
        add_degree_to_csv(degree)
      end
    end

    def add_degree_to_csv(degree)
      csv_rows(degree).each { |row| csv << row }
    end

    def csv_rows(degree)
      subjects = resolve_degree_subjects(degree)

      if subjects.empty?
        [build_fallback_row(degree)]
      else
        subjects.map { |subject| build_subject_row(degree, subject) }
      end
    end

    def resolve_degree_subjects(degree)
      top_level_subject = degree_subject(degree)
      return [] unless top_level_subject

      if direct_hecos_code?(top_level_subject)
        [top_level_subject]
      elsif multi_subjects?(top_level_subject)
        expand_multi_subjects(top_level_subject)
      else
        []
      end
    end

    def direct_hecos_code?(subject)
      subject&.hecos_code.present?
    end

    def multi_subjects?(subject)
      subject&.subject_ids.present?
    end

    def expand_multi_subjects(top_level_subject)
      top_level_subject.subject_ids.filter_map do |subject_id|
        DfEReference::DegreesQuery::SUBJECTS.one(subject_id)
      end
    end

    def build_fallback_row(degree)
      build_csv_row(
        degree.trainee.trn,
        degree.trainee.date_of_birth.iso8601,
        trainee_nino(degree.trainee),
        "", # Empty HECOS code
        degree.subject,
      )
    end

    def build_subject_row(degree, subject)
      build_csv_row(
        degree.trainee.trn,
        degree.trainee.date_of_birth.iso8601,
        trainee_nino(degree.trainee),
        subject.hecos_code,
        subject.name,
      )
    end

    def build_csv_row(*values)
      values.map { |value| CsvValueSanitiser.new(value).sanitise }
    end

    def degree_subject(degree)
      return nil if degree.subject_uuid.blank?

      DfEReference::DegreesQuery::SUBJECTS.one(degree.subject_uuid)
    end

    def trainee_nino(trainee)
      trainee.hesa_trainee_detail&.ni_number
    end
  end
end
