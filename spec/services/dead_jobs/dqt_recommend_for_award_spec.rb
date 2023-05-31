# frozen_string_literal: true

require "rails_helper"

RSpec.describe DeadJobs::DqtRecommendForAward do
  it_behaves_like "Dead jobs", Dqt::RecommendForAwardJob, "DQT Recommend For Award"
end
