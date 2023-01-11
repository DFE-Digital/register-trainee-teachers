# frozen_string_literal: true

require "rails_helper"

module DeadJobs
  describe DqtUpdateTrainee do
    it_behaves_like "DeadJobs", "Dqt::UpdateTraineeJob", "Dqt update trainee"
  end
end
