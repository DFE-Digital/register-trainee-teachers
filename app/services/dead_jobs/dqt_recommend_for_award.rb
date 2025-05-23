# frozen_string_literal: true

module DeadJobs
  class DqtRecommendForAward < Base
  private

    # Full class name to look for in Sidekiq dead jobs
    def klass
      "Dqt::RecommendForAwardJob"
    end
  end
end
