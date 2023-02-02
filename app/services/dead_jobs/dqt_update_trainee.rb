# frozen_string_literal: true

module DeadJobs
  class DqtUpdateTrainee < Base
    # includes the error_message entry using `includes: ...`
    def to_csv(includes: [])
      build_csv(includes: %i[job_id error_message params_sent] | includes)
    end

  private

    def build_rows
      super do |trainee|
        { params_sent: Dqt::Params::TraineeRequest.new(trainee:).to_json&.to_s&.gsub('"', "'") }
      end
    end

    # full class name to look for in Sidekiq dead jobs
    def klass
      "Dqt::UpdateTraineeJob"
    end
  end
end
