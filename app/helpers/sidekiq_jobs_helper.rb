# frozen_string_literal: true

module SidekiqJobsHelper
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
