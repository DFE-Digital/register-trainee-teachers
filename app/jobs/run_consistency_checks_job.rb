# frozen_string_literal: true

class RunConsistencyChecksJob < ApplicationJob
  queue_as :default

  def perform(*_args)
    ConsistencyCheck.all.each do |consistency_check|
      Dttp::CheckConsistencyJob.perform_later(consistency_check.id)
    end
  end
end
