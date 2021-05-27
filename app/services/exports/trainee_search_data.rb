# frozen_string_literal: true

module Exports
  class TraineeSearchData
    def initialize(trainees, include_provider: false)
      @data_for_export = format_trainees(trainees, include_provider)
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

    def format_trainees(trainees, include_provider)
      trainees.map do |trainee|
        {
          "First name" => trainee.first_names,
          "Last name" => trainee.last_name,
          "Trainee Id" => trainee.trainee_id,
          "TRN" => trainee.trn,
          "Status" => status(trainee),
          "Route" => trainee.training_route,
          "Subject" => trainee.subject,
          "Course start date" => trainee.course_start_date,
          "Course end date" => trainee.course_end_date,
          "Created date" => trainee.created_at,
          "Last updated date" => trainee.updated_at,
          "TRN Submitted date" => trainee.submitted_for_trn_at,
          "Award submitted date" => trainee.recommended_for_award_at,
        }.tap do |fields|
          fields.merge!("Provider Name" => trainee.provider.name) if include_provider
        end
      end
    end

    def status(trainee)
      I18n.t("activerecord.attributes.trainee.states.#{trainee.state}", award_type: trainee.award_type)
    end
  end
end
