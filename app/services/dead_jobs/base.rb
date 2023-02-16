# frozen_string_literal: true

module DeadJobs
  class Base
    DEFAULT_HEADERS = %i[
      register_id
      trainee_name
      trainee_trn
      trainee_dob
      trainee_state
      provider_name
      provider_ukprn
      programme_route
      programme_start_date
      programme_end_date
    ].freeze

    def initialize(dead_set: Sidekiq::DeadSet.new, include_dqt_status: false)
      @dead_set = dead_set
      @include_dqt_status = include_dqt_status
    end

    # includes the error_message entry using `includes: ...`
    def to_csv(includes: [])
      build_csv(includes: %i[job_id error_message] | includes)
    end

    # by default only use the defined headers in DEFAULT_HEADERS
    # so as not to clutter the html view
    def headers(includes: [])
      return if rows.blank?

      rows(includes:).first.keys
    end

    # by default only use the defined headers in DEFAULT_HEADERS
    # so as not to clutter the html view
    def rows(includes: [])
      build_rows.map do |row|
        row.slice(*(DEFAULT_HEADERS | includes))
      end
    end

    def name
      @name ||= identifier.titleize.gsub("Dqt", "DQT")
    end

    def identifier
      @identifier ||= self.class.name.demodulize
    end

    delegate :count, to: :dead_jobs

  private

    attr_reader :dead_set, :include_dqt_status

    def trainees
      Trainee.includes(:provider).find(dead_jobs.keys)
    end

    def build_csv(includes:)
      CSV.generate do |csv|
        csv << headers(includes:)
        rows(includes:).each do |row|
          csv << row.values
        end
      end
    end

    def build_rows
      @build_rows ||= trainees.map do |trainee|
        dqt_trn_params = Dqt::Params::TrnRequest.new(trainee:).params
        {
          register_id: trainee.id,
          trainee_name: trainee.full_name,
          trainee_trn: trainee.trn,
          trainee_dob: trainee.date_of_birth,
          trainee_state: trainee.state,
          provider_name: trainee.provider.name,
          provider_ukprn: trainee.provider.ukprn,
          programme_route: dqt_trn_params.dig("initialTeacherTraining", "programmeType"),
          programme_start_date: dqt_trn_params.dig("initialTeacherTraining", "programmeStartDate"),
          programme_end_date: dqt_trn_params.dig("initialTeacherTraining", "programmeEndDate"),
          job_id: dead_jobs[trainee.id][:job_id],
          error_message: dead_jobs[trainee.id][:error_message]&.to_s&.gsub('"', "'"),
        }.tap do |row|
          row.merge!(yield(trainee)) if block_given?
          row.merge!(dqt_status: dqt_status(trainee))
        end
      end
    end

    # returns: [{ record_id => error_message }, ... ]
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

    def dqt_status(trainee)
      return unless include_dqt_status && trainee.trn.present?

      Dqt::RetrieveTrainingInstance.call(trainee:)["result"]&.to_s&.gsub('"', "'")
    rescue StandardError => e
      "error: #{e.message}"
    end

    def parse_error(error)
      return error unless error.include?("body: ")

      JSON.parse(
        error.split("body: ")
             .last
             .split(", headers:")
             .first,
      )
    rescue JSON::ParserError
      error
    end
  end
end
