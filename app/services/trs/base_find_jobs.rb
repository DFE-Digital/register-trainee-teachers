# frozen_string_literal: true

module Trs
  class BaseFindJobs
    include ServicePattern

    def call
      sidekiq_class.new
      .select { |job| job.item["wrapped"] == "Trs::UpdateProfessionalStatusJob" }
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
