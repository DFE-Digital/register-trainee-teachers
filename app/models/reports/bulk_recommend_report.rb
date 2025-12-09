# frozen_string_literal: true

module Reports
  class BulkRecommendReport < TemplateClassCsv
    DO_NOT_EDIT   = "Do not edit"
    DATE_GUIDANCE = "For example, 20/7/2022\nDelete row if the trainee's QTS or EYTS status is not changing"

    # required headers
    TRN = "TRN"
    PROVIDER_TRAINEE_ID = "Provider trainee ID"
    HESA_ID = "HESA ID"

    IDENTIFIERS = [TRN, PROVIDER_TRAINEE_ID, HESA_ID].freeze
    DATE        = "Date QTS or EYTS status changed"

    # additional headers
    FIRST_NAME   = "First names"
    LAST_NAME    = "Last names"
    LEAD_PARTNER = "Lead partner"
    QTS_OR_EYTS  = "QTS or EYTS"
    ROUTE        = "Route"
    PHASE        = "Phase"
    AGE_RANGE    = "Age range"
    SUBJECT      = "Subject"

    DEFAULT_HEADERS = [
      *IDENTIFIERS,
      FIRST_NAME,
      LAST_NAME,
      LEAD_PARTNER,
      QTS_OR_EYTS,
      ROUTE,
      PHASE,
      AGE_RANGE,
      SUBJECT,
      DATE,
    ].freeze

    def initialize(csv, scope:)
      @csv = csv
      @scope = scope
    end

    def headers
      @headers ||=
        if hesa_id?
          DEFAULT_HEADERS
        else
          DEFAULT_HEADERS - ["HESA ID"]
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
      # ["Do not edit", "Do not edit" ... DATE_GUIDANCE]
      csv << [*(headers.count - 1).times.map { DO_NOT_EDIT }, DATE_GUIDANCE]
    end

    def add_report_rows
      return csv << ["No trainee data to export"] if trainees.blank?

      post_header_row!
      trainees.strict_loading.includes(:degrees,
                                       { course_allocation_subject: [:subject_specialisms] },
                                       :end_academic_cycle,
                                       :start_academic_cycle,
                                       :provider,
                                       :withdrawal_reasons,
                                       :lead_partner).each do |trainee| # rubocop:disable Rails/FindEach
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
        trainee_report.first_names,
        trainee_report.last_names,
        trainee_report.lead_partner_name,
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
