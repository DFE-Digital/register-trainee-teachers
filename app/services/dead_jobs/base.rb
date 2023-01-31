# frozen_string_literal: true

module DeadJobs
  class Base
    def initialize(dead_set: Sidekiq::DeadSet.new, include_dqt_status: false)
      @dead_set = dead_set
      @include_dqt_status = include_dqt_status
    end

    # includes the error_message entry using `includes: ...`
    def to_csv
      @to_csv ||= CSV.generate do |csv|
        csv << headers(includes: %i[error_message job_id])
        rows(includes: %i[error_message job_id]).each do |row|
          csv << row.values
        end
      end
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
      to_a.map do |row|
        row.slice(*(DEFAULT_HEADERS | includes))
      end
    end

    def name
      @name ||= identifier.titleize.gsub("Dqt", "DQT")
    end

    delegate :count, to: :dead_jobs

  private

    attr_reader :dead_set, :include_dqt_status

    DEFAULT_HEADERS = %i[register_id trainee_name trainee_trn trainee_dob trainee_state provider_name provider_ukprn].freeze

    def identifier
      @identifier ||= self.class.name.demodulize
    end

    def trainees
      Trainee.includes(:provider).find(dead_jobs.keys)
    end

    def to_a
      @to_a ||= trainees.map do |trainee|
        {
          job_id: dead_jobs[trainee.id][:job_id],
          register_id: trainee.id,
          trainee_name: trainee.full_name,
          trainee_trn: trainee.trn,
          trainee_dob: trainee.date_of_birth,
          trainee_state: trainee.state,
          provider_name: trainee.provider.name,
          provider_ukprn: trainee.provider.ukprn,
          error_message: dead_jobs[trainee.id][:error_message]&.to_s&.gsub('"', "'"),
          dqt_status: dqt_status(trainee),
        }
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

      Dqt::RetrieveTeacher.call(trainee:).dig("initial_teacher_training", "result")&.to_s&.gsub('"', "'")
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
