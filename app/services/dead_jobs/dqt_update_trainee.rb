# frozen_string_literal: true

module DeadJobs
  class DqtUpdateTrainee < Base
    # includes the error_message entry using `includes: ...`
    def to_csv
      @to_csv ||= CSV.generate do |csv|
        csv << headers(includes: %i[error_message job_id params_sent])
        rows(includes: %i[error_message job_id params_sent]).each do |row|
          csv << row.values
        end
      end
    end

  private

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
          params_sent: Dqt::Params::TraineeRequest.new(trainee:).to_json&.to_s&.gsub('"', "'"),
          dqt_status: dqt_status(trainee),
        }
      end
    end

    # full class name to look for in Sidekiq dead jobs
    def klass
      "Dqt::UpdateTraineeJob"
    end
  end
end
