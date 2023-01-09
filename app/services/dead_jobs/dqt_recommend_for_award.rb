# frozen_string_literal: true

module DeadJobs
  class DqtRecommendForAward < Base
    def initialize(with_errors: false, with_params: false)
      @with_errors = with_errors
      @with_params = with_params
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

  private

    attr_reader :with_errors, :with_params

    # full class name to look for in Sidekiq dead jobs
    def klass
      "Dqt::RecommendForAwardJob"
    end

    def trainees
      Trainee.includes(:provider).find(dead_jobs.keys)
    end
  end
end
