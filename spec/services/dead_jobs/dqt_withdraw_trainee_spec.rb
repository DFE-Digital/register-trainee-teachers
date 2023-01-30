# frozen_string_literal: true

require "rails_helper"

module DeadJobs
  describe DqtWithdrawTrainee do
    it_behaves_like "DeadJobs" do
      let(:klass) { "Dqt::WithdrawTraineeJob" }
      let(:name) { "Dqt withdraw trainee" }
    end
  end
end
