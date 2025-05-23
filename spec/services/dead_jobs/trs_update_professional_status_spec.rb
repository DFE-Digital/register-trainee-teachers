# frozen_string_literal: true

require "rails_helper"

RSpec.describe DeadJobs::TrsUpdateProfessionalStatus do
  it_behaves_like "Dead jobs", Trs::UpdateProfessionalStatusJob, "TRS Update Professional Status"
end
