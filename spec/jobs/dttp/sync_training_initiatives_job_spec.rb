# frozen_string_literal: true

require "rails_helper"

module Dttp
  describe SyncTrainingInitiativesJob do
    include ActiveJob::TestHelper

    let(:training_initiative_one_hash) { create(:api_training_initiative) }
    let(:training_initiative_two_hash) { create(:api_training_initiative) }
    let(:next_page_url) { "https://some-url.com" }

    let(:trainee_list) do
      {
        items: [training_initiative_one_hash, training_initiative_two_hash],
        meta: { next_page_url: next_page_url },
      }
    end

    subject { described_class.perform_now }

    before do
      enable_features(:sync_trainees_from_dttp)
      allow(RetrieveTrainingInitiatives).to receive(:call) { trainee_list }
    end

    it "enqueues job with the next_page_url" do
      expect {
        subject
      }.to have_enqueued_job(described_class).with("https://some-url.com")
    end

    context "when the Dttp::TrainingInitiative is not in register" do
      it "creates a Dttp::TrainingInitiative record for each unique trainee" do
        expect {
          subject
        }.to change(Dttp::TrainingInitiative, :count).by(2)
      end
    end

    context "when a Dttp::TrainingInitiative exists" do
      let(:dttp_training_initiative) do
        create(:dttp_training_initiative, dttp_id: training_initiative_one_hash["dfe_initiativeid"])
      end

      before do
        dttp_training_initiative
      end

      it "updates the existing record" do
        subject
        expect(dttp_training_initiative.reload.response).to eq(training_initiative_one_hash)
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
