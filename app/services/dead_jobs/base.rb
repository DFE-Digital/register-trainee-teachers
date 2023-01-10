# frozen_string_literal: true

module DeadJobs
  class Base
    def initialize(with_errors: false, with_params: false)
      @with_errors = with_errors
      @with_params = with_params
    end

    def csv
      CSV.generate do |csv|
        csv << headers
        rows.each do |row|
          csv << row.values
        end
      end
    end

    def headers
      return if rows.blank?

      @headers ||= rows.first.keys
    end

    def rows
      @rows ||= to_a
    end

    def name
      @name ||= identifier.underscore.humanize
    end

    def identifier
      @identifier ||= self.class.name.demodulize
    end

    delegate :count, to: :dead_jobs

  private

    attr_reader :with_errors, :with_params

    def trainees
      Trainee.includes(:provider).find(dead_jobs.keys)
    end

    def to_a
      @to_a ||= trainees.map do |trainee|
        {
          register_id: trainee.id,
          trainee_name: trainee.full_name,
          trainee_trn: trainee.trn,
          trainee_dob: trainee.date_of_birth,
          provider_name: trainee.provider.name,
          provider_ukprn: trainee.provider.ukprn,
          error_message: (dead_jobs[trainee.id] if with_errors),
          params_sent: (Dqt::Params::TraineeRequest.new(trainee:) if with_params),
        }.compact
      end
    end

    # returns: [{ record_id => error_message }, ... ]
    def dead_jobs
      @dead_jobs ||=
        Sidekiq::DeadSet
        .new
        .select { _1.item["wrapped"] == klass }
        .to_h do |job|
          [job.item["args"].first["arguments"].first["_aj_globalid"].split("/").last.to_i, job["error_message"]]
        end
    end
  end
end
