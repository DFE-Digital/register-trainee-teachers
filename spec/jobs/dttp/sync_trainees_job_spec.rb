# frozen_string_literal: true

require "rails_helper"

module Dttp
  describe SyncTraineesJob do
    include ActiveJob::TestHelper

    let(:trainee_one_hash) { create(:api_trainee) }
    let(:trainee_two_hash) { create(:api_trainee) }
    let(:next_page_url) { "https://some-url.com" }

    let(:trainee_list) do
      {
        items: [trainee_one_hash, trainee_two_hash],
        meta: { next_page_url: next_page_url },
      }
    end

    subject { described_class.perform_now }

    before do
      enable_features(:sync_trainees_from_dttp)
      allow(RetrieveTrainees).to receive(:call) { trainee_list }
    end

    it "enqueues job with the next_page_url" do
      expect {
        subject
      }.to have_enqueued_job(described_class).with("https://some-url.com")
    end

    context "when the Dttp:Trainee is not in register" do
      it "creates a Dttp::Trainee record for each unique trainee" do
        expect {
          subject
        }.to change(Dttp::Trainee, :count).by(2)
      end
    end

    context "when a Dttp::Trainee exists" do
      let(:dttp_trainee) { create(:dttp_trainee, dttp_id: trainee_one_hash["contactid"]) }

      before do
        dttp_trainee
      end

      it "updates the existing record" do
        subject
        expect(dttp_trainee.reload.response).to eq(trainee_one_hash)
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
