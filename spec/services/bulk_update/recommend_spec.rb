# frozen_string_literal: true

require "rails_helper"

module BulkUpdate
  describe Recommend do
    let(:recommendations_upload_row) { create(:bulk_update_recommendations_upload_row, trainee:) }
    let(:recommendations_upload) { recommendations_upload_row.recommendations_upload }

    subject { described_class.call(recommendations_upload:) }

    before do
      allow(::Trainees::FindDuplicatesOfHesaTrainee).to receive(:call).and_return([])
      allow(::Trainees::UpdateIttData).to receive(:call)
    end

    describe "#call" do
      context "when the trainee is trn_received" do
        let(:trainee) { create(:trainee, :trn_received) }

        it "updates the trainees state and outcome date" do
          expect { subject }
            .to change { trainee.reload.state }
            .from("trn_received").to("recommended_for_award")
            .and change { trainee.outcome_date }
            .from(nil).to(recommendations_upload_row.standards_met_at)
        end

        it "calls the UpdateIttData service" do
          subject
          expect(::Trainees::UpdateIttData).to have_received(:call).with(trainee:)
        end
      end

      context "when the trainee is not trn_received" do
        let(:trainee) { create(:trainee, :draft) }

        it "does not update the trainee state and outcome date" do
          subject
          expect(trainee.reload.state).to eql "draft"
          expect(trainee.outcome_date).to be_nil
        end

        it "does not call the UpdateIttData service" do
          subject
          expect(::Trainees::UpdateIttData).not_to have_received(:call).with(trainee:)
        end
      end
    end
  end
end
