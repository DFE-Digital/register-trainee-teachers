# frozen_string_literal: true

require "rails_helper"

module Trainees
  describe Withdraw do
    let(:trainee) { create(:trainee) }
    let(:withdrawal_reasons) { [] }
    let(:withdrawal) { double(withdrawal_reasons:) }
    let(:delayed_job) { double(perform_later: true) }
    let(:reason_names) { ["Valid Reason"] }
    let(:days_delayed) { 7 }

    before do
      allow(Dqt::WithdrawTraineeJob).to receive(:perform_later)
      allow(Trs::UpdateProfessionalStatusJob).to receive(:perform_later)
      allow(Survey::SendJob).to receive(:set).and_return(delayed_job)
      allow(trainee).to receive(:current_withdrawal).and_return(withdrawal)
      allow(withdrawal_reasons).to receive(:pluck).with(:name).and_return(reason_names)
      allow(Settings).to receive_message_chain(:qualtrics, :days_delayed).and_return(days_delayed)
      allow(FeatureService).to receive(:enabled?).and_return(false)
    end

    describe "#call" do
      context "when DQT integration is enabled and TRS is disabled", feature_integrate_with_dqt: true, feature_integrate_with_trs: false do
        before do
          allow(FeatureService).to receive(:enabled?).with(:integrate_with_dqt).and_return(true)
          allow(FeatureService).to receive(:enabled?).with(:integrate_with_trs).and_return(false)
        end

        it "queues a withdrawal to DQT" do
          expect(Dqt::WithdrawTraineeJob).to receive(:perform_later).with(trainee)
          expect(Trs::UpdateProfessionalStatusJob).not_to receive(:perform_later)
          described_class.call(trainee:)
        end
      end

      context "when TRS integration is enabled", feature_integrate_with_dqt: false, feature_integrate_with_trs: true do
        before do
          allow(FeatureService).to receive(:enabled?).with(:integrate_with_dqt).and_return(false)
          allow(FeatureService).to receive(:enabled?).with(:integrate_with_trs).and_return(true)
        end

        it "queues an update to TRS" do
          expect(Trs::UpdateProfessionalStatusJob).to receive(:perform_later).with(trainee)
          expect(Dqt::WithdrawTraineeJob).not_to receive(:perform_later)
          described_class.call(trainee:)
        end
      end

      context "when both TRS and DQT integrations are enabled", feature_integrate_with_dqt: true, feature_integrate_with_trs: true do
        before do
          allow(FeatureService).to receive(:enabled?).with(:integrate_with_dqt).and_return(true)
          allow(FeatureService).to receive(:enabled?).with(:integrate_with_trs).and_return(true)
        end

        it "raises a ConflictingIntegrationsError" do
          expect {
            described_class.call(trainee:)
          }.to raise_error(HandlesIntegrationConflicts::ConflictingIntegrationsError)
        end
      end

      context "when neither integration is enabled", feature_integrate_with_dqt: false, feature_integrate_with_trs: false do
        before do
          allow(FeatureService).to receive(:enabled?).with(:integrate_with_dqt).and_return(false)
          allow(FeatureService).to receive(:enabled?).with(:integrate_with_trs).and_return(false)
        end

        it "does not queue any integration jobs" do
          expect(Trs::UpdateProfessionalStatusJob).not_to receive(:perform_later)
          expect(Dqt::WithdrawTraineeJob).not_to receive(:perform_later)
          described_class.call(trainee:)
        end
      end

      context "when there are no withdrawal reasons" do
        let(:reason_names) { [] }

        it "does not schedule a survey" do
          expect(Survey::SendJob).not_to receive(:set)
          described_class.call(trainee:)
        end
      end

      context "when RECORD_ADDED_IN_ERROR is the only reason" do
        let(:reason_names) { [WithdrawalReasons::RECORD_ADDED_IN_ERROR] }

        it "does not schedule a survey" do
          expect(Survey::SendJob).not_to receive(:set)
          described_class.call(trainee:)
        end
      end

      context "when there are other reasons besides RECORD_ADDED_IN_ERROR" do
        let(:reason_names) { [WithdrawalReasons::RECORD_ADDED_IN_ERROR, "Another Reason"] }

        it "schedules a survey with the configured delay" do
          allow(Survey::SendJob).to receive(:set).with(wait: days_delayed.days).and_return(delayed_job)
          described_class.call(trainee:)
          expect(Survey::SendJob).to have_received(:set).with(wait: days_delayed.days)
          expect(delayed_job).to have_received(:perform_later).with(trainee: trainee, event_type: :withdraw)
        end
      end

      context "when there are only valid reasons" do
        let(:reason_names) { ["Valid Reason"] }

        it "schedules a survey with the configured delay" do
          allow(Survey::SendJob).to receive(:set).with(wait: days_delayed.days).and_return(delayed_job)
          described_class.call(trainee:)
          expect(Survey::SendJob).to have_received(:set).with(wait: days_delayed.days)
          expect(delayed_job).to have_received(:perform_later).with(trainee: trainee, event_type: :withdraw)
        end
      end
    end
  end
end
