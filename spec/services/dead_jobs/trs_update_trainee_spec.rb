# frozen_string_literal: true

require "rails_helper"

RSpec.describe DeadJobs::TrsUpdateTrainee do
  it_behaves_like "Dead jobs", Trs::UpdateTraineeJob, "TRS Update Trainee"
end
