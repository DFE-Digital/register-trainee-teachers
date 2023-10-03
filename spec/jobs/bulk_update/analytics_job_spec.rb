# frozen_string_literal: true

require "rails_helper"

RSpec.describe BulkUpdate::AnalyticsJob do
  include ActiveJob::TestHelper

  let(:trainees) { create_list(:trainee, 3, :trn_received) }
  let(:ids) { trainees.map(&:id) }
  let(:model) { Trainee }

  describe "#perform" do
    it "calls the SendEvents.do method" do
      allow(DfE::Analytics::SendEvents).to receive(:do)

      described_class.perform_now(model:, ids:)

      expect(DfE::Analytics::SendEvents).to have_received(:do)
    end
  end
end
