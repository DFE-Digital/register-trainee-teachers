# frozen_string_literal: true

module DeadJobs
  class Base
    def csv
      CSV.generate do |csv|
        csv << headers
        rows.each do |row|
          csv << row.values
        end
      end
    end

    def headers
      return if rows.blank?

      @headers ||= rows.first.keys
    end

    def rows
      @rows ||= to_a
    end

    def name
      @name ||= identifier.underscore.humanize
    end

    def identifier
      @identifier ||= self.class.name.demodulize
    end

    delegate :count, to: :dead_jobs

  private

    # returns: [{ record_id => error_message }, ... ]
    def dead_jobs
      @dead_jobs ||=
        Sidekiq::DeadSet
        .new
        .select { _1.item["wrapped"] == klass }
        .to_h do |job|
          [job.item["args"].first["arguments"].first["_aj_globalid"].split("/").last.to_i, job["error_message"]]
        end
    end
  end
end
