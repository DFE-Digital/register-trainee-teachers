# frozen_string_literal: true

require "rails_helper"

module Trainees
  describe Update do
    let(:trainee) { create(:trainee, :trn_received) }

    describe "conflicting integrations" do
      context "when both integrations are enabled", feature_integrate_with_dqt: true, feature_integrate_with_trs: true do
        it "raises an error when both feature flags are enabled" do
          expect {
            described_class.call(trainee:)
          }.to raise_error(HandlesIntegrationConflicts::ConflictingIntegrationsError, "Both DQT and TRS integrations are enabled. Only one should be active at a time.")
        end

        it "does not raise an error if update_dqt is false" do
          expect {
            described_class.call(trainee: trainee, update_dqt: false)
          }.not_to raise_error
        end
      end
    end

    describe "updating trainees" do
      context "valid params" do
        let(:params) { { first_names: "Dave", last_name: "Hill" } }

        context "with DQT integration enabled", feature_integrate_with_dqt: true, feature_integrate_with_trs: false do
          before do
            allow(Dqt::UpdateTraineeJob).to receive(:perform_later)
          end

          it "updates the trainee" do
            described_class.call(trainee:, params:)
            trainee.reload
            expect(trainee.first_names).to eq("Dave")
            expect(trainee.last_name).to eq("Hill")
          end

          it "queues an update to DQT" do
            described_class.call(trainee:, params:)
            expect(Dqt::UpdateTraineeJob).to have_received(:perform_later).with(trainee)
          end

          it "does not queue updates when update_dqt is false" do
            described_class.call(trainee: trainee, params: params, update_dqt: false)
            expect(Dqt::UpdateTraineeJob).not_to have_received(:perform_later)
          end

          it "does not queue a withdrawal to DQT when `withdrawal` option is not set" do
            expect(Dqt::WithdrawTraineeJob).not_to receive(:perform_later).with(trainee)
            described_class.call(trainee:, params:)
          end

          it "returns true" do
            expect(described_class.call(trainee:, params:)).to be(true)
          end

          context "with invalid states" do
            it "does not queue updates for trainee without TRN" do
              trainee_without_trn = create(:trainee, trn: nil)
              described_class.call(trainee: trainee_without_trn, params: params)
              expect(Dqt::UpdateTraineeJob).not_to have_received(:perform_later)
            end

            it "does not queue updates for withdrawn trainee" do
              withdrawn_trainee = create(:trainee, :withdrawn, trn: "12345678")
              described_class.call(trainee: withdrawn_trainee, params: params)
              expect(Dqt::UpdateTraineeJob).not_to have_received(:perform_later)
            end

            it "does not queue updates for awarded trainee" do
              awarded_trainee = create(:trainee, :awarded, trn: "12345678")
              described_class.call(trainee: awarded_trainee, params: params)
              expect(Dqt::UpdateTraineeJob).not_to have_received(:perform_later)
            end
          end
        end

        context "with TRS integration enabled", feature_integrate_with_dqt: false, feature_integrate_with_trs: true do
          before do
            allow(Trs::UpdateTraineeJob).to receive(:perform_later)
            allow(Trs::UpdateProfessionalStatusJob).to receive(:perform_later)
          end

          it "queues an update to TRS" do
            described_class.call(trainee:, params:)
            expect(Trs::UpdateTraineeJob).to have_received(:perform_later).with(trainee)
            expect(Trs::UpdateProfessionalStatusJob).to have_received(:perform_later).with(trainee)
          end

          it "does not queue updates when update_dqt is false" do
            described_class.call(trainee: trainee, params: params, update_dqt: false)
            expect(Trs::UpdateTraineeJob).not_to have_received(:perform_later)
            expect(Trs::UpdateProfessionalStatusJob).not_to have_received(:perform_later)
          end

          context "with a deferred trainee" do
            let(:deferred_trainee) { create(:trainee, :deferred, trn: "12345678") }

            it "queues both personal data and professional status updates" do
              described_class.call(trainee: deferred_trainee, params: params)
              expect(Trs::UpdateTraineeJob).to have_received(:perform_later).with(deferred_trainee)
              expect(Trs::UpdateProfessionalStatusJob).to have_received(:perform_later).with(deferred_trainee)
            end
          end

          context "with invalid states" do
            it "does not queue updates for trainee without TRN" do
              trainee_without_trn = create(:trainee, trn: nil)
              described_class.call(trainee: trainee_without_trn, params: params)
              expect(Trs::UpdateTraineeJob).not_to have_received(:perform_later)
              expect(Trs::UpdateProfessionalStatusJob).not_to have_received(:perform_later)
            end

            it "does not queue updates for withdrawn trainee" do
              withdrawn_trainee = create(:trainee, :withdrawn, trn: "12345678")
              described_class.call(trainee: withdrawn_trainee, params: params)
              expect(Trs::UpdateTraineeJob).not_to have_received(:perform_later)
              expect(Trs::UpdateProfessionalStatusJob).not_to have_received(:perform_later)
            end

            it "does not queue updates for awarded trainee" do
              awarded_trainee = create(:trainee, :awarded, trn: "12345678")
              described_class.call(trainee: awarded_trainee, params: params)
              expect(Trs::UpdateTraineeJob).not_to have_received(:perform_later)
              expect(Trs::UpdateProfessionalStatusJob).not_to have_received(:perform_later)
            end
          end
        end

        context "with integrations disabled", feature_integrate_with_dqt: false, feature_integrate_with_trs: false do
          before do
            allow(Dqt::UpdateTraineeJob).to receive(:perform_later)
            allow(Trs::UpdateTraineeJob).to receive(:perform_later)
            allow(Trs::UpdateProfessionalStatusJob).to receive(:perform_later)
          end

          it "does not queue updates when both features are disabled" do
            described_class.call(trainee:, params:)
            expect(Dqt::UpdateTraineeJob).not_to have_received(:perform_later)
            expect(Trs::UpdateTraineeJob).not_to have_received(:perform_later)
            expect(Trs::UpdateProfessionalStatusJob).not_to have_received(:perform_later)
          end
        end

        it "raises an error if trainee is invalid" do
          expect {
            described_class.call(trainee: nil, params: params)
          }.to raise_error(NoMethodError)
        end
      end

      context "passed a trainee that has had attributes set", feature_integrate_with_dqt: true, feature_integrate_with_trs: false do
        before do
          allow(Dqt::UpdateTraineeJob).to receive(:perform_later)
        end

        context "with no params" do
          it "persists any changes" do
            trainee.first_names = "Baldric"
            described_class.call(trainee:)
            trainee.reload
            expect(trainee.first_names).to eq("Baldric")
          end
        end

        context "with params" do
          it "persists any changes with the params" do
            trainee.first_names = "Baldric"
            described_class.call(trainee: trainee, params: { last_name: "Bladder" })
            trainee.reload
            expect(trainee.first_names).to eq("Baldric")
            expect(trainee.last_name).to eq("Bladder")
          end
        end
      end
    end
  end
end
