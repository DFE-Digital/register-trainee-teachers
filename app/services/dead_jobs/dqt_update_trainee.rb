# frozen_string_literal: true

module DeadJobs
  class DqtUpdateTrainee < Base
  private

    def build_csv_row(trainee)
      super.merge(params_sent: params_sent(trainee))
    end

    def params_sent(trainee)
      flatten_hash(Dqt::Params::Update.new(trainee:).params.compact)
    end

    # Full class name to look for in Sidekiq dead jobs
    def klass
      "Dqt::UpdateTraineeJob"
    end
  end
end
