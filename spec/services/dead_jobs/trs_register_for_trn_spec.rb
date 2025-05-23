# frozen_string_literal: true

require "rails_helper"

RSpec.describe DeadJobs::TrsRegisterForTrn do
  it_behaves_like "Dead jobs", Trs::RegisterForTrnJob, "TRS Register For Trn"
end
