# frozen_string_literal: true

require "rails_helper"

RSpec.describe DeadJobs::TrsRetrieveTrn do
  it_behaves_like "Dead jobs", Trs::RetrieveTrnJob, "TRS Retrieve Trn"
end
