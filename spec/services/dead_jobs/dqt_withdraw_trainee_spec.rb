# frozen_string_literal: true

require "rails_helper"

module DeadJobs
  describe DqtWithdrawTrainee do
    it_behaves_like "DeadJobs", "Dqt::WithdrawTraineeJob", "Dqt withdraw trainee"
  end
end
