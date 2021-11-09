# frozen_string_literal: true

require "rails_helper"

module Trainees
  describe SubmitForTrn do
    let(:trainee) { create(:trainee, :draft, :completed) }
    let(:dttp_id) { SecureRandom.uuid }

    subject { described_class.call(trainee: trainee, dttp_id: dttp_id) }

    it "queues a background job to register trainee for TRN" do
      expect {
        subject
      }.to have_enqueued_job(Dttp::RegisterForTrnJob).with(trainee, dttp_id)
    end

    it "queues a background job to poll for the trainee's TRN" do
      expect(Dttp::RetrieveTrnJob).to receive(:perform_with_default_delay).with(trainee)
      subject
    end

    context "trainee state" do
      it "transitions the trainee state to submitted_for_trn" do
        expect {
          subject
        }.to change {
          trainee.state
        }.from("draft").to("submitted_for_trn")
      end
    end
  end
end
