# frozen_string_literal: true

require "rails_helper"

RSpec.describe BulkUpdate::AnalyticsJob do
  include ActiveJob::TestHelper

  let(:trainees) { create_list(:trainee, 3, :trn_received) } # Adjust the number and trait as needed
  let(:ids) { trainees.map(&:id) }
  let(:model) { Trainee }

  describe "#perform" do
    it "calls the SendEvents.do method" do
      allow(DfE::Analytics::SendEvents).to receive(:do)

      described_class.perform_now(model:, ids:)

      expect(DfE::Analytics::SendEvents).to have_received(:do)
      # Add any other expectations for arguments or other methods that should have been triggered.
    end
  end
end
