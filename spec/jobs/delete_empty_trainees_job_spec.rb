# frozen_string_literal: true

require "rails_helper"

describe DeleteEmptyTraineesJob do
  include ActiveJob::TestHelper

  let(:provider) { create(:provider) }

  before do
    Trainee.create(provider: provider, training_route: TRAINING_ROUTE_ENUMS[:assessment_only])
  end

  it "enqueues job" do
    expect {
      described_class.perform_later
    }.to have_enqueued_job
  end

  it "deletes empty trainee records" do
    expect { described_class.perform_now }.to change { Trainee.count }.from(1).to(0)
  end
end
