# frozen_string_literal: true

require "rails_helper"

module DeadJobs
  describe DqtRecommendForAward do
    it_behaves_like "DeadJobs" do
      let(:klass) { "Dqt::RecommendForAwardJob" }
      let(:name) { "DQT Recommend For Award" }
    end
  end
end
