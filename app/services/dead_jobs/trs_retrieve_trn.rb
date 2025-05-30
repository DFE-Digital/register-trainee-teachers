# frozen_string_literal: true

module DeadJobs
  class TrsRetrieveTrn < Base
  private

    # Full class name to look for in Sidekiq dead jobs
    def klass
      "Trs::RetrieveTrnJob"
    end
  end
end
