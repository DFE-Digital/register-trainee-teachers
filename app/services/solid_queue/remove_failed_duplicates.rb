# frozen_string_literal: true

module SolidQueue
  class RemoveFailedDuplicates
    include ServicePattern
    include Hashable

    attr_reader :failed_executions, :set

    def initialize
      @set               = Set.new
      @failed_executions = SolidQueue::FailedExecution.includes(:job).order(id: :desc)
    end

    def call
      failed_executions.each do |execution|
        error      = execution.message&.split(",")&.first
        arguments  = execution.job.arguments.dig("arguments", 0)
        trainee_id = deep_dig(arguments, "_aj_globalid")&.split("/")&.last

        next unless error && trainee_id

        digest = [error, execution.job.class_name, trainee_id].join

        if set.include?(digest)
          execution.discard
        else
          set.add(digest)
        end
      end
    end
  end
end
