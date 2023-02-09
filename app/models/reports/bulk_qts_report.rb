# frozen_string_literal: true

module Reports
  class BulkQtsReport < TemplateClassCsv
    def self.headers
      [
        "TRN",
        "Provider trainee ID",
        "HESA ID",
        "HESA NUMHUS",
        "Last names",
        "First names",
        "Lead school",
        "QTS or EYTS",
        "Route",
        "Phase",
        "Age range",
        "Subject",
        "End academic year",
        "Date QTS or EYTS standards met",
      ].compact
    end

    alias trainees scope

  private

    def add_headers
      csv << self.class.headers
    end

    def post_header_row!
      last_row = <<~TEXT
        "For example, 20/7/2022

        Leave empty if the trainee has not met the standards"
      TEXT

      # ["Do not edit", "Do not edit" ... last_row]
      csv << [*(self.class.headers.count - 1).times.map { "Do not edit" }, last_row]
    end

    def add_report_rows
      return csv << ["No trainee data to export"] if trainees.blank?

      post_header_row!
      trainees.strict_loading.includes(:apply_application,
                                       { course_allocation_subject: [:subject_specialisms] },
                                       :degrees, :disabilities,
                                       :employing_school,
                                       :end_academic_cycle,
                                       :lead_school,
                                       { nationalisations: :nationality },
                                       :nationalities,
                                       :provider,
                                       :start_academic_cycle,
                                       :trainee_disabilities).in_batches.each_record do |trainee|
        add_trainee_to_csv(trainee)
      end
    end

    def add_trainee_to_csv(trainee)
      csv << csv_row(trainee)
    end

    def csv_row(trainee)
      trainee_report = Reports::TraineeReport.new(trainee)

      [
        trainee_report.trn,
        trainee_report.provider_trainee_id,
        trainee_report.hesa_id,
        1, # hesa numhus not yet in schema
        trainee_report.last_names,
        trainee_report.first_names,
        trainee_report.lead_school_name,
        trainee_report.qts_or_eyts,
        trainee_report.course_training_route,
        trainee_report.course_education_phase,
        trainee_report.course_age_range,
        trainee_report.course_subject_category,
        trainee_report.end_academic_year,
      ].map { |value| CsvValueSanitiser.new(value).sanitise }
    end
  end
end
