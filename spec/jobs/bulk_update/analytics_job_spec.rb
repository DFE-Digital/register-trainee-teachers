# frozen_string_literal: true

require "rails_helper"

RSpec.describe BulkUpdate::AnalyticsJob do
  include ActiveJob::TestHelper

  let(:trainees) { create_list(:trainee, 3, :trn_received) }
  let(:ids) { trainees.map(&:id) }
  let(:model) { Trainee }

  describe "#perform" do
    before { disable_dfe_analytics }

    it "does not calls the SendEvents.do method" do
      allow(DfE::Analytics::SendEvents).to receive(:do)

      described_class.perform_now(model:, ids:)

      expect(DfE::Analytics::SendEvents).not_to have_received(:do)
    end
  end

  context "when the feature flag is turned on", "feature_google.send_data_to_big_query": true do
    describe "#perform" do
      before { enable_dfe_analytics }

      it "calls the SendEvents.do method" do
        allow(DfE::Analytics::SendEvents).to receive(:do)

        described_class.perform_now(model:, ids:)

        expect(DfE::Analytics::SendEvents).to have_received(:do).at_least(:once)
      end
    end
  end
end
