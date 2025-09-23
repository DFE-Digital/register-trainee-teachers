# frozen_string_literal: true

require "rails_helper"

module Trainees
  describe UpdateIttDataInTra do
    let(:trainee) { create(:trainee, :trn_received) }

    describe "#call" do
      context "when TRS integration is enabled", feature_integrate_with_trs: true do
        it "calls TRS update professional status job" do
          expect(Trs::UpdateProfessionalStatusJob).to receive(:perform_later).with(trainee)
          described_class.call(trainee:)
        end
      end

      context "when trainee doesn't have a TRN", feature_integrate_with_trs: true do
        let(:trainee) { create(:trainee) }

        it "doesn't call any jobs" do
          expect(Trs::UpdateProfessionalStatusJob).not_to receive(:perform_later)
          expect(Trs::UpdateTraineeJob).not_to receive(:perform_later)
          described_class.call(trainee:)
        end
      end
    end
  end
end
