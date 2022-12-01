# frozen_string_literal: true

require "rails_helper"

module Dqt
  describe RetrieveAwardJob do
    let(:trainee) { create(:trainee, :trn_received) }
    let(:trn_request) { create(:dqt_trn_request, trainee:) }
    let(:dqt_response) do
      { "qualified_teacher_status" => { "qts_date" => award_date } }
    end

    before do
      enable_features(:integrate_with_dqt)
      allow(Dqt::RetrieveTeacher).to receive(:call).with(trainee:).and_return(dqt_response)
    end

    context "qts_date is present" do
      let(:award_date) { 5.days.ago.iso8601 }

      it "updates the trainee but not DQT" do
        expect(Trainees::Update).to receive(:call).with(trainee: trainee,
                                                        params: { awarded_at: award_date },
                                                        update_dqt: false)
        described_class.perform_now(trainee)
      end
    end

    context "qts_date is nil" do
      let(:award_date) { nil }

      it "doesn't update the trainee" do
        expect(Trainees::Update).not_to receive(:call)

        described_class.perform_now(trainee)
      end
    end
  end
end
