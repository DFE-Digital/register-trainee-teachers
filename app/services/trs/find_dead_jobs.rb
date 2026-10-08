# frozen_string_literal: true

module Trs
  class FindDeadJobs < BaseFindJobs
    def sidekiq_class
      Sidekiq::DeadSet
    end

  private

    def solid_queue_executions
      SolidQueue::FailedExecution.includes(:job)
    end

    def solid_queue_error_message(execution)
      execution.message
    end

    def solid_queue_scheduled_at(execution)
      execution.created_at
    end
  end
end
