# frozen_string_literal: true

require "rails_helper"

RSpec.describe DeadJobs::DqtWithdrawTrainee do
  it_behaves_like "Dead jobs", Dqt::WithdrawTraineeJob, "DQT Withdraw Trainee"
end
