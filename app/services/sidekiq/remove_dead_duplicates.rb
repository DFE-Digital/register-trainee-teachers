# frozen_string_literal: true

module Sidekiq
  class RemoveDeadDuplicates
    include ServicePattern
    include Hashable

    attr_reader :dead_jobs, :set

    def initialize
      @set       = Set.new
      @dead_jobs = Sidekiq::DeadSet.new
    end

    def call
      dead_jobs.each do |job|
        error      = job.item["error_message"]&.split(",")&.first
        arguments  = job.args.dig(0, "arguments", 0)
        trainee_id = deep_dig(arguments, "_aj_globalid")&.split("/")&.last

        next unless error && trainee_id

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
