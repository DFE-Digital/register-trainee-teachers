# frozen_string_literal: true

require "rails_helper"

module Dttp
  describe SyncDormantPeriodsJob do
    include ActiveJob::TestHelper

    let(:dormant_period_one_hash) { create(:api_dormant_period) }
    let(:dormant_period_two_hash) { create(:api_dormant_period) }
    let(:next_page_url) { "https://some-url.com" }

    let(:trainee_list) do
      {
        items: [dormant_period_one_hash, dormant_period_two_hash],
        meta: { next_page_url: },
      }
    end

    subject { described_class.perform_now }

    before do
      enable_features(:sync_trainees_from_dttp)
      allow(RetrieveDormantPeriods).to receive(:call) { trainee_list }
    end

    it "enqueues job with the next_page_url" do
      expect {
        subject
      }.to have_enqueued_job(described_class).with("https://some-url.com")
    end

    context "when the Dttp::DormantPeriod is not in register" do
      it "creates a Dttp::DormantPeriod record for each unique trainee" do
        expect {
          subject
        }.to change(Dttp::DormantPeriod, :count).by(2)
      end
    end

    context "when a Dttp::DormantPeriod exists" do
      let(:dttp_dormant_period) { create(:dttp_dormant_period, dttp_id: dormant_period_one_hash["dfe_dormantperiodid"]) }

      before do
        dttp_dormant_period
      end

      it "updates the existing record" do
        subject
        expect(dttp_dormant_period.reload.response).to eq(dormant_period_one_hash)
      end
    end

    context "when next_page_url is not available" do
      let(:next_page_url) { nil }

      it "does not enqueue any further jobs" do
        expect {
          subject
        }.not_to have_enqueued_job(described_class)
      end
    end
  end
end
