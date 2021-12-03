# frozen_string_literal: true

require "rails_helper"

module Dttp
  describe SyncDegreeQualificationsJob do
    include ActiveJob::TestHelper

    let(:degree_qualification_one_hash) { create(:api_degree_qualification) }
    let(:degree_qualification_two_hash) { create(:api_degree_qualification) }
    let(:next_page_url) { "https://some-url.com" }

    let(:degree_qualification_list) do
      {
        items: [degree_qualification_one_hash, degree_qualification_two_hash],
        meta: { next_page_url: next_page_url },
      }
    end

    subject { described_class.perform_now }

    before do
      enable_features(:sync_trainees_from_dttp)
      allow(RetrieveDegreeQualifications).to receive(:call) { degree_qualification_list }
    end

    it "enqueues job with the next_page_url" do
      expect {
        subject
      }.to have_enqueued_job(described_class).with("https://some-url.com")
    end

    context "when the Dttp:DegreeQualification is not in register" do
      it "creates a Dttp::DegreeQualification record for each unique degree qualification" do
        expect {
          subject
        }.to change(Dttp::DegreeQualification, :count).by(2)
      end
    end

    context "when a Dttp::DegreeQualification exists" do
      let(:dttp_degree_qualification) { create(:dttp_degree_qualification, dttp_id: degree_qualification_one_hash["dfe_degreequalificationid"]) }

      before do
        dttp_degree_qualification
      end

      it "updates the existing record" do
        subject
        expect(dttp_degree_qualification.reload.response).to eq(degree_qualification_one_hash)
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
