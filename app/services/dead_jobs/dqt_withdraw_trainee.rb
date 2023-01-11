# frozen_string_literal: true

module DeadJobs
  class DqtWithdrawTrainee < Base
  private

    # full class name to look for in Sidekiq dead jobs
    def klass
      "Dqt::WithdrawTraineeJob"
    end
  end
end
