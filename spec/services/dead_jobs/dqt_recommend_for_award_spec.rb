# frozen_string_literal: true

require "rails_helper"

module DeadJobs
  describe DqtRecommendForAward do
    it_behaves_like "DeadJobs", "Dqt::RecommendForAwardJob", "Dqt recommend for award"
  end
end
