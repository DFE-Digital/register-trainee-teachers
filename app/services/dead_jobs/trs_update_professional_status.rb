# frozen_string_literal: true

module DeadJobs
  class TrsUpdateProfessionalStatus < Base
  private

    # Full class name to look for in Sidekiq dead jobs
    def klass
      "Trs::UpdateProfessionalStatusJob"
    end
  end
end
