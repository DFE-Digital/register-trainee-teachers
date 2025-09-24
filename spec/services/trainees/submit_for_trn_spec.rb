# frozen_string_literal: true

require "rails_helper"

module Trainees
  describe SubmitForTrn do
    let(:trainee) { create(:trainee, :draft, :completed) }

    subject { described_class.call(trainee:) }

    before { ActiveJob::Base.queue_adapter = :test }

    context "when TRS integration is enabled", feature_integrate_with_trs: true do
      it "enqueues a background job to register trainee for TRN with TRS" do
        expect {
          subject
        }.to have_enqueued_job(Trs::RegisterForTrnJob).with(trainee)
      end

      it "transitions the trainee state to submitted_for_trn" do
        expect {
          subject
        }.to change {
          trainee.state
        }.from("draft").to("submitted_for_trn")
      end
    end

    context "when both integrations are enabled", feature_integrate_with_dqt: true, feature_integrate_with_trs: true do
      it "raises a ConflictingIntegrationsError" do
        expect {
          subject
        }.to raise_error(HandlesIntegrationConflicts::ConflictingIntegrationsError)
      end
    end
  end
end
