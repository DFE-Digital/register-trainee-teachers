# frozen_string_literal: true

require "rails_helper"

module Dqt
  describe SyncTraineeTrnJob do
    let(:trainee) { create(:trainee, :submitted_for_trn) }
    let(:dqt_teacher) {
      {
        "trn" => trn,
        "firstName" => trainee.first_names,
        "lastName" => trainee.last_name,
        "dateOfBirth" => trainee.date_of_birth,
      }
    }

    before do
      allow(FindTeacher).to receive(:call).with(trainee: trainee).and_return(dqt_teacher)
    end

    context "when a TRN is returned" do
      let(:trn) { "0123456" }

      it "updates the trainee's TRN to what is in DQT and transitions them to trn_received", feature_integrate_with_dqt: true do
        expect {
          described_class.perform_now(trainee.id)
        }.to change {
          trainee.reload.trn
        }.to(trn)
        .and change {
          trainee.state
        }.to("trn_received")
      end
    end

    context "when a TRN is not returned" do
      let(:trn) { nil }

      it "raises an error", feature_integrate_with_dqt: true do
        expect {
          described_class.perform_now(trainee.id)
        }.to raise_error(SyncTraineeTrnJob::Error, "No TRN found in DQT for trainee: #{trainee.id}")
      end
    end
  end
end
