# frozen_string_literal: true

module DeadJobs
  class TrsUpdateTrainee < Base
  private

    # full class name to look for in Sidekiq dead jobs
    def klass
      "Trs::UpdateTraineeJob"
    end
  end
end
