# frozen_string_literal: true

require "csv"

module Exports
  class ReportCsvEnumeratorService
    include ServicePattern

    def initialize(data, csv = CSV)
      @data = data
      @csv = csv
    end

    def call
      Enumerator.new do |yielder|
        yielder << csv.generate_line(headers)
        trainees.find_each do |trainee|
          yielder << csv.generate_line(trainee_report(trainee))
        end
        yielder
      end
    end

  private

    attr_accessor :data, :csv

    def trainees
      @trainees ||= data.strict_loading.includes(:apply_application,
                                                 { course_allocation_subject: %i[subject_specialisms funding_methods] },
                                                 :degrees, :disabilities,
                                                 :employing_school,
                                                 :end_academic_cycle,
                                                 :training_partner,
                                                 { nationalisations: :nationality },
                                                 :nationalities,
                                                 :provider,
                                                 :start_academic_cycle,
                                                 :trainee_disabilities,
                                                 { placements: :school },
                                                 :hesa_students,
                                                 :withdrawal_reasons)
    end

    def headers = Reports::TraineesReport.headers

    def trainee_report(trainee)
      trainee_report = Reports::TraineeReport.new(trainee)
      headers.map { |header| CsvValueSanitiser.new(trainee_report.public_send(header)).sanitise }
    end
  end
end
