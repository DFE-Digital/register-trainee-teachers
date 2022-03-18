# frozen_string_literal: true

require "rails_helper"

module Dqt
  describe RecommendForAward do
    let(:trainee) { create(:trainee, :recommended_for_award) }
    let(:award_date) { Time.zone.today.iso8601 }
    let(:dqt_response) {
      {
        "trn" => trainee.trn,
        "qtsDate" => award_date,
      }
    }

    subject { described_class.call(trainee: trainee) }

    describe "#call" do
      before do
        enable_features(:integrate_with_dqt)
        allow(Dqt::Client).to receive(:put).and_return(dqt_response)
      end

      it "returns the award date" do
        expect(subject).to eq(award_date)
      end
    end
  end
end
