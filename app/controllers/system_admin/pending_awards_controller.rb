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
      @dead_jobs ||= Dqt::FindDeadJobsService.call
    end

    def retry_jobs
      @retry_jobs ||= Dqt::FindRetryJobsService.call
    end
  end
end

module Dqt
  class BaseFindJobsService
    include ServicePattern

    def call
      sidekiq_class.new
      .select { |job| job.item["wrapped"] == "Dqt::RecommendForAwardJob" }
      .sort_by { |job| job.item["enqueued_at"] }
      .to_h do |job|
        [
          job.item["args"].first["arguments"].first["_aj_globalid"].split("/").last.to_i,
          {
            job_id: job.item["jid"],
            error_message: parse_error(job.item["error_message"]),
            scheduled_at: job.at,
          },
        ]
      end
    end

  private

    def parse_error(error)
      return error unless error.include?("body: ")

      JSON.parse(
        error.split("body: ")
             .last
             .split(", headers:")
             .first,
      )
    rescue JSON::ParserError
      error
    end
  end
end

module Dqt
  class FindDeadJobsService < BaseFindJobsService
    def sidekiq_class
      Sidekiq::DeadSet
    end
  end
end

module Dqt
  class FindRetryJobsService < BaseFindJobsService
    def sidekiq_class
      Sidekiq::RetrySet
    end
  end
end
