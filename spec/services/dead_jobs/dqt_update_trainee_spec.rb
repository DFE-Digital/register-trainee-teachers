# frozen_string_literal: true

require "rails_helper"

RSpec.describe DeadJobs::DqtUpdateTrainee do
  it_behaves_like "Dead jobs", Dqt::UpdateTraineeJob, "DQT Update Trainee"
end
