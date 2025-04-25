# frozen_string_literal: true

require "rails_helper"

module Trainees
  describe UpdateIttDataInTra do
    let(:trainee) { create(:trainee, :trn_received) }

    describe "#call" do
      context "when TRS integration is enabled", feature_integrate_with_dqt: false, feature_integrate_with_trs: true do
        it "calls TRS update professional status job" do
          expect(Trs::UpdateProfessionalStatusJob).to receive(:perform_later).with(trainee)
          described_class.call(trainee:)
        end
      end

      context "when DQT integration is enabled", feature_integrate_with_dqt: true, feature_integrate_with_trs: false do
        context "when trainee is recommended for award" do
          let(:trainee) { create(:trainee, :trn_received, :recommended_for_award) }

          it "calls DQT recommend for award job" do
            expect(Dqt::RecommendForAwardJob).to receive(:perform_later).with(trainee)
            described_class.call(trainee:)
          end
        end

        context "when trainee is withdrawn" do
          let(:trainee) { create(:trainee, :trn_received, :withdrawn) }

          it "calls DQT withdraw trainee job" do
            expect(Dqt::WithdrawTraineeJob).to receive(:perform_later).with(trainee)
            described_class.call(trainee:)
          end
        end

        context "when trainee is in a valid update state" do
          let(:trainee) { create(:trainee, :trn_received) }

          it "calls DQT update trainee job" do
            expect(Dqt::UpdateTraineeJob).to receive(:perform_later).with(trainee)
            described_class.call(trainee:)
          end
        end
      end

      context "when trainee doesn't have a TRN" do
        let(:trainee) { create(:trainee) }

        it "doesn't call any jobs" do
          expect(Trs::UpdateProfessionalStatusJob).not_to receive(:perform_later)
          expect(Dqt::RecommendForAwardJob).not_to receive(:perform_later)
          expect(Dqt::WithdrawTraineeJob).not_to receive(:perform_later)
          expect(Dqt::UpdateTraineeJob).not_to receive(:perform_later)
          described_class.call(trainee:)
        end
      end
    end
  end
end
