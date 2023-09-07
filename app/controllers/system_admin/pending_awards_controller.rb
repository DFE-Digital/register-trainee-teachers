# frozen_string_literal: true

module SystemAdmin
  class PendingAwardsController < ApplicationController
    add_flash_types :dqt_error

    helper_method :last_run_or_scheduled_at, :job_status

    def index
      @trainees = Trainee.recommended_for_award.undiscarded.order(:recommended_for_award_at)
    end

    def last_run_or_scheduled_at(trainee)
      if dead_jobs[trainee.id]
        dead_jobs[trainee.id][:scheduled_at]
      elsif retry_jobs[trainee.id]
        retry_jobs[trainee.id][:scheduled_at]
      end
    end

    def job_status(trainee)
      if dead_jobs[trainee.id]
        "dead"
      elsif retry_jobs[trainee.id]
        "retrying"
      else
        "unknown"
      end
    end

  private

    def dead_jobs
      @dead_jobs ||= Dqt::FindDeadJobs.call
    end

    def retry_jobs
      @retry_jobs ||= Dqt::FindRetryJobs.call
    end
  end
end
