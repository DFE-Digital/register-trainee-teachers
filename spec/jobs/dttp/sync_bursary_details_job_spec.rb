# frozen_string_literal: true

require "rails_helper"

module Dttp
  describe SyncBursaryDetailsJob do
    include ActiveJob::TestHelper

    let(:bursary_detail_one_hash) { create(:api_bursary_detail) }
    let(:bursary_detail_two_hash) { create(:api_bursary_detail) }
    let(:next_page_url) { "https://some-url.com" }

    let(:trainee_list) do
      {
        items: [bursary_detail_one_hash, bursary_detail_two_hash],
        meta: { next_page_url: },
      }
    end

    subject { described_class.perform_now }

    before do
      enable_features(:sync_trainees_from_dttp)
      allow(RetrieveBursaryDetails).to receive(:call) { trainee_list }
    end

    it "enqueues job with the next_page_url" do
      expect {
        subject
      }.to have_enqueued_job(described_class).with("https://some-url.com")
    end

    context "when the Dttp::BursaryDetail is not in register" do
      it "creates a Dttp::BursaryDetail record for each unique trainee" do
        expect {
          subject
        }.to change(Dttp::BursaryDetail, :count).by(2)
      end
    end

    context "when a Dttp::BursaryDetail exists" do
      let(:dttp_bursary_detail) { create(:dttp_bursary_detail, dttp_id: bursary_detail_one_hash["dfe_bursarydetailid"]) }

      before do
        dttp_bursary_detail
      end

      it "updates the existing record" do
        subject
        expect(dttp_bursary_detail.reload.response).to eq(bursary_detail_one_hash)
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
