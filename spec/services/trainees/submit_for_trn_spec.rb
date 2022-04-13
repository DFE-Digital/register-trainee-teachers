# frozen_string_literal: true

require "rails_helper"

module Trainees
  describe SubmitForTrn do
    let(:trainee) { create(:trainee, :draft, :completed) }

    subject { described_class.call(trainee: trainee) }

    context "persist_to_dttp enabled", feature_persist_to_dttp: true do
      it "queues a background job to poll for the trainee's TRN" do
        expect(Dttp::RetrieveTrnJob).to receive(:perform_with_default_delay).with(trainee)
        subject
      end

      it "transitions the trainee state to submitted_for_trn" do
        expect {
          subject
        }.to change {
          trainee.state
        }.from("draft").to("submitted_for_trn")
      end
    end

    context "integrate_with_dqt enabled", feature_integrate_with_dqt: true do
      it "queues a background job to register trainee for TRN" do
        expect {
          subject
        }.to have_enqueued_job(Dqt::RegisterForTrnJob).with(trainee)
      end

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
