# frozen_string_literal: true

require "rails_helper"

module Dqt
  describe SyncStatesJob do
    let!(:trainee) { create(:trainee, state, :imported_from_hesa) }
    let(:award_date) { nil }
    let(:result) { nil }
    let(:dqt_response) do
      {
        "qualified_teacher_status" => { "qts_date" => award_date },
        "initial_teacher_training" => { "result" => result },
      }
    end

    before do
      enable_features(:integrate_with_dqt)
      allow(Dqt::RetrieveTeacher).to receive(:call).with(trainee: trainee).and_return(dqt_response)
    end

    context "when the Register trainee is not trn_received" do
      let(:state) { "awarded" }

      it "is a no-op" do
        expect(Dqt::RetrieveTeacher).not_to receive(:call)

        described_class.perform_now
      end
    end

    context "when the Register trainee is trn_received" do
      let(:state) { "trn_received" }

      context "but not from HESA" do
        before do
          trainee.update!(hesa_id: nil)
        end

        it "is a no-op" do
          expect(Dqt::RetrieveTeacher).not_to receive(:call)

          described_class.perform_now
        end
      end

      context "but the TRN is not 7-digits" do
        before do
          trainee.update!(trn: "123456")
        end

        it "is a no-op" do
          expect(Dqt::RetrieveTeacher).not_to receive(:call)

          described_class.perform_now
        end
      end

      context "and the dqt state is Pass" do
        let(:result) { "Pass" }

        context "and there's an award date in DQT" do
          let(:award_date) { Date.yesterday }

          it "transitions the trainee to awarded" do
            expect { described_class.perform_now }
              .to change { trainee.reload.state }.from("trn_received").to("awarded")
              .and change { trainee.reload.awarded_at }.from(nil).to(Date.yesterday)
          end
        end

        context "and there no award date in DQT" do
          it "does not transisiton the trainee to awarded" do
            expect { described_class.perform_now }
              .not_to change { trainee.state }
          end
        end
      end

      context "and the dqt state is not Pass" do
        let(:result) { "Withdrawn" }

        it "does not transisiton the trainee" do
          expect { described_class.perform_now }
            .not_to change { trainee.state }
        end
      end
    end
  end
end
