# frozen_string_literal: true

require "rails_helper"

module DeadJobs
  describe DqtWithdrawTrainee do
    it_behaves_like "DeadJobs" do
      let(:klass) { "Dqt::WithdrawTraineeJob" }
      let(:name) { "DQT Withdraw Trainee" }
    end
  end
end
