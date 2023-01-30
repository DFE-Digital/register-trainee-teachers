# frozen_string_literal: true

module Sidekiq
  class RemoveDeadDuplicates
    include ServicePattern

    attr_reader :dead_jobs, :set

    def initialize
      @set = Set.new
      @dead_jobs = Sidekiq::DeadSet.new
    end

    def call
      dead_jobs.each do |job|
        error = job.item["error_message"].split(",").first
        trainee_id = job.args[0]["arguments"][0]["_aj_globalid"].split("/").last

        digest = [error, job.display_class, trainee_id].join

        if set.include?(digest)
          job.delete
        else
          set.add(digest)
        end
      end
    end
  end
end
