# frozen_string_literal: true

module Exports
  class TraineeSearchData
    def initialize(trainees)
      @data_for_export = format_trainees(trainees)
    end

    def data
      header_row ||= data_for_export.first&.keys

      CSV.generate(headers: true) do |rows|
        rows << header_row

        data_for_export.map(&:values).each do |value|
          rows << value
        end
      end
    end

    def filename
      "#{Time.zone.now.strftime('%Y-%m-%d_%H-%M_%S')}_Register-trainee-teachers_exported_records.csv"
    end

  private

    attr_reader :data_for_export

    def format_trainees(trainees)
      trainees.map do |trainee|
        {
          "First name" => trainee.first_names,
          "Last name" => trainee.last_name,
          "Trainee Id" => trainee.trainee_id,
          "TRN" => trainee.trn,
          "Status" => trainee.state,
          "Route" => trainee.training_route,
          "Subject" => trainee.subject,
          "Programme start date" => trainee.programme_start_date,
          "Programme end date" => trainee.programme_end_date,
          "Created date" => trainee.created_at,
          "Last updated date" => trainee.updated_at,
          "TRN Submitted date" => trainee.submitted_for_trn_at,
          "QTS submitted date" => trainee.recommended_for_qts_at,
        }
      end
    end
  end
end
