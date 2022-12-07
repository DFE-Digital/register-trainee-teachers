# frozen_string_literal: true

require "rails_helper"

module Dqt
  describe SyncState do
    let!(:trainee) { create(:trainee, :trn_received, :imported_from_hesa) }
    let(:award_date) { nil }
    let(:result) { nil }
    let(:dqt_response) do
      {
        "qualified_teacher_status" => { "qts_date" => award_date },
        "initial_teacher_training" => { "result" => result },
      }
    end

    subject { described_class.call(trainee:) }

    before do
      enable_features(:integrate_with_dqt)
      allow(Dqt::RetrieveTeacher).to receive(:call).with(trainee:).and_return(dqt_response)
    end

    context "and the dqt state is Pass" do
      let(:result) { "Pass" }
      let(:award_date) { Date.yesterday }

      it "transitions the trainee to awarded" do
        expect { subject }
          .to change { trainee.reload.state }.from("trn_received").to("awarded")
          .and change { trainee.reload.awarded_at }.from(nil).to(Date.yesterday)
      end
    end

    context "and the dqt state is Withdrawn" do
      let(:result) { "Withdrawn" }

      it "transisitons the trainee to withdrawn and sets the withdrawal reason to unknown" do
        expect { subject }
          .to change { trainee.reload.state }.from("trn_received").to("withdrawn")
          .and change { trainee.reload.withdraw_reason }.from(nil).to(WithdrawalReasons::UNKNOWN)
      end
    end

    context "and the dqt state is Deferred" do
      let(:result) { "Deferred" }

      it "transisitons the trainee to deferred" do
        expect { subject }
          .to change { trainee.reload.state }.from("trn_received").to("deferred")
      end
    end

    context "and the dqt state is In Training" do
      let(:result) { "In Training" }

      it "does not transisiton the trainee" do
        expect { subject }
          .not_to change { trainee.reload.state }
      end
    end
  end
end
