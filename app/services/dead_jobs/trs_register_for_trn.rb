# frozen_string_literal: true

module DeadJobs
  class TrsRegisterForTrn < Base
  private

    # Full class name to look for in Sidekiq dead jobs
    def klass
      "Trs::RegisterForTrnJob"
    end
  end
end
