# frozen_string_literal: true

module Trs
  class FindRetryJobs < BaseFindJobs
    def sidekiq_class
      Sidekiq::RetrySet
    end

  private

    def solid_queue_executions
      SolidQueue::ScheduledExecution.includes(:job).select do |execution|
        execution.job.arguments["executions"].to_i.positive?
      end
    end

    def solid_queue_error_message(_execution); end

    def solid_queue_scheduled_at(execution)
      execution.scheduled_at
    end
  end
end
