# frozen_string_literal: true

module Trs
  class BaseFindJobs
    include ServicePattern

    JOB_CLASS = "Trs::UpdateProfessionalStatusJob"

    def call
      sidekiq_jobs.merge(solid_queue_jobs)
    end

  private

    def sidekiq_jobs
      sidekiq_class.new
      .select { |job| job.item["wrapped"] == JOB_CLASS }
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

    def solid_queue_jobs
      solid_queue_executions
      .select { |execution| execution.job.class_name == JOB_CLASS }
      .sort_by(&:created_at)
      .to_h do |execution|
        [
          execution.job.arguments.dig("arguments", 0, "_aj_globalid").split("/").last.to_i,
          {
            job_id: execution.job.active_job_id,
            error_message: parse_error(solid_queue_error_message(execution)),
            scheduled_at: solid_queue_scheduled_at(execution),
          },
        ]
      end
    end

    def parse_error(error)
      return error unless error&.include?("body: ")

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
