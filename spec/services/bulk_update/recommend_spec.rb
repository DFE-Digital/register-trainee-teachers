# frozen_string_literal: true

require "rails_helper"

module BulkUpdate
  describe Recommend do
    let(:recommendations_upload_row) { create(:bulk_update_recommendations_upload_row, trainee:) }
    let(:recommendations_upload) { recommendations_upload_row.recommendations_upload }

    subject { described_class.call(recommendations_upload:) }

    before do
      allow(Dqt::RecommendForAwardJob).to receive(:perform_later)
    end

    describe "#call", feature_integrate_with_dqt: true do
      context "when the trainee is trn_received" do
        let(:trainee) { create(:trainee, :trn_received) }

        it "updates the trainees state and outcome date" do
          expect { subject }
            .to change { trainee.reload.state }
            .from("trn_received").to("recommended_for_award")
            .and change { trainee.outcome_date }
            .from(nil).to(recommendations_upload_row.standards_met_at)
        end

        it "kicks off a job to recommend them for award with DQT" do
          expect(Dqt::RecommendForAwardJob).to receive(:perform_later).with(trainee)
          subject
        end
      end

      context "when the trainee is already awarded" do
        let(:trainee) { create(:trainee, :awarded) }

        it "does not kick off a job to recommend them for award with DQT" do
          expect(Dqt::RecommendForAwardJob).not_to receive(:perform_later).with(trainee)
          subject
        end
      end
    end
  end
end
