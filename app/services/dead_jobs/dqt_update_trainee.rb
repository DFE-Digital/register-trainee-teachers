# frozen_string_literal: true

module DeadJobs
  class DqtUpdateTrainee < Base
  private

    # full class name to look for in Sidekiq dead jobs
    def klass
      "Dqt::UpdateTraineeJob"
    end
  end
end
