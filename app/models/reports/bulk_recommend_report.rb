# frozen_string_literal: true

module Reports
  class BulkRecommendReport < TemplateClassCsv
    DEFAULT_HEADERS = [
      "TRN",
      "Provider trainee ID",
      "Last names",
      "First names",
      "Lead school",
      "QTS or EYTS",
      "Route",
      "Phase",
      "Age range",
      "Subject",
      "Date QTS or EYTS standards met",
    ].freeze

    def initialize(csv, scope:)
      @csv = csv
      @scope = scope
    end

    def headers
      @headers ||=
        if hesa_id?
          DEFAULT_HEADERS.insert(2, "HESA ID")
        else
          DEFAULT_HEADERS
        end
    end

    alias trainees scope

  private

    def hesa_id?
      return @hesa_id if defined?(@hesa_id)

      @hesa_id = trainees.pluck(:hesa_id).compact.any?
    end

    def add_headers
      csv << headers
    end

    def post_header_row!
      last_row = <<~TEXT
        For example, 20/7/2022

        Delete row if the trainee has not met the standards
      TEXT

      # ["Do not edit", "Do not edit" ... last_row]
      csv << [*(headers.count - 1).times.map { "Do not edit" }, last_row]
    end

    def add_report_rows
      return csv << ["No trainee data to export"] if trainees.blank?

      post_header_row!
      trainees.strict_loading.includes(:degrees,
                                       { course_allocation_subject: [:subject_specialisms] },
                                       :end_academic_cycle,
                                       :start_academic_cycle,
                                       :provider,
                                       :lead_school).each do |trainee| # rubocop:disable Rails/FindEach
        add_trainee_to_csv(trainee)
      end
    end

    def add_trainee_to_csv(trainee)
      csv << csv_row(trainee)
    end

    def csv_row(trainee)
      trainee_report = Reports::TraineeReport.new(trainee)

      row = [
        trainee_report.trn,
        trainee_report.provider_trainee_id,
        trainee_report.hesa_id,
        trainee_report.last_names,
        trainee_report.first_names,
        trainee_report.lead_school_name.presence || "-",
        trainee_report.qts_or_eyts,
        trainee_report.course_training_route,
        trainee_report.course_education_phase,
        trainee_report.course_age_range,
        trainee_report.subjects,
      ].map { |value| CsvValueSanitiser.new(value).sanitise }

      row.delete_at(2) unless hesa_id?
      row
    end
  end
end
