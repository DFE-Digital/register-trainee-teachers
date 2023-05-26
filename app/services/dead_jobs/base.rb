# frozen_string_literal: true

module DeadJobs
  class Base
    def initialize(dead_set: Sidekiq::DeadSet.new, include_dqt_status: false)
      @dead_set = dead_set
      @include_dqt_status = include_dqt_status
    end

    def to_csv
      CSV.generate do |csv|
        csv << csv_headers
        trainees.each do |trainee|
          csv << build_csv_row(trainee).values
        end
      end
    end

    def headers
      return if rows.blank?

      rows.first.keys
    end

    def rows
      @rows ||= trainees.map { |trainee| build_html_row(trainee) }
    end

    def name
      @name ||= identifier.titleize.gsub("Dqt", "DQT")
    end

    def identifier
      @identifier ||= self.class.name.demodulize
    end

    def trainees
      Trainee.includes(:provider).find(dead_jobs.keys)
    end

    delegate :count, to: :dead_jobs

  private

    attr_reader :dead_set, :include_dqt_status

    def csv_headers
      build_csv_row(trainees.first).keys
    end

    def build_csv_row(trainee)
      dqt_params = dqt_params(trainee)
      {
        id: trainee.id,
        job_id: dead_jobs[trainee.id][:job_id],
        url: "#{Settings.base_url}/trainees/#{trainee.slug}",
        trn: trainee.trn,
        date_of_birth: trainee.date_of_birth,
        full_name: trainee.full_name,
        email: trainee.email,
        state: trainee.state,
        provider_name: trainee.provider.name,
        provider_ukprn: trainee.provider.ukprn,
        training_route: trainee.training_route,
        itt_start_date: trainee.itt_start_date,
        itt_end_date: trainee.itt_start_date,
        course_min_age: trainee.course_min_age,
        course_max_age: trainee.course_max_age,
        course_subject_one: trainee.course_subject_one,
        course_subject_two: trainee.course_subject_two,
        course_subject_three: trainee.course_subject_three,
        dqt_programme_route: (dqt_params.dig("initialTeacherTraining", "programmeType") if include_dqt_status),
        dqt_programme_start_date: (dqt_params.dig("initialTeacherTraining", "programmeStartDate") if include_dqt_status),
        dqt_programme_end_date: (dqt_params.dig("initialTeacherTraining", "programmeEndDate") if include_dqt_status),
        error_message: dead_job_error_message(trainee.id),
      }
    end

    def build_html_row(trainee)
      {
        register_id: trainee.id,
        trn: trainee.trn,
        name: trainee.full_name,
        date_of_birth: trainee.date_of_birth,
        state: trainee.state,
        job_id: dead_jobs[trainee.id][:job_id],
      }
    end

    def dqt_params(trainee)
      @dqt_params ||= {}
      @dqt_params[trainee.id] ||= Dqt::Params::TrnRequest.new(trainee:).params
    end

    def dead_jobs
      @dead_jobs ||=
        dead_set
        .select { |job| job.item["wrapped"] == klass }
        .to_h do |job|
          [
            job.item["args"].first["arguments"].first["_aj_globalid"].split("/").last.to_i,
            {
              error_message: parse_error(job.item["error_message"]),
              job_id: job.item["jid"],
            },
          ]
        end
    end

    def dead_job_error_message(trainee_id)
      dead_jobs[trainee_id][:error_message]&.to_s&.gsub('"', "'")
    end

    def parse_error(error)
      return error unless error.include?("body: ")

      parsed = JSON.parse(
        error.split("body: ")
             .last
             .split(", headers:")
             .first,
      )
    rescue JSON::ParserError
      error
    end

    def flatten_hash(hash, parent_key = "", result = "")
      hash.each do |key, value|
        new_key = parent_key == "" ? "#{key}" : "#{parent_key}_#{key}"
        if value.is_a? Hash
          result = flatten_hash(value, new_key, result)
        else
          result += "#{new_key}: #{value}\n"
        end
      end
      result
    end
  end
end
