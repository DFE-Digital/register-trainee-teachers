# frozen_string_literal: true

require "rails_helper"

module Dqt
  describe RecommendForAwardJob do
    let(:award_date) { nil }
    let(:trainee) { create(:trainee, :recommended_for_award) }

    before do
      enable_features(:integrate_with_dqt)
      allow(RecommendForAward).to receive(:call).with(trainee: trainee).and_return(award_date)
      allow(SlackNotifierService).to receive(:call)
    end

    context "we receive an award date" do
      let(:award_date) { Time.zone.today.iso8601 }

      it "updates the trainee awarded_at attribute" do
        expect {
          described_class.perform_now(trainee)
        }.to change(trainee, :awarded_at).to(Time.zone.parse(award_date))
      end

      context "DTQ sha" do
        let(:trainee_sha) { "ABC" }

        before do
          allow(trainee).to receive(:sha).and_return(trainee_sha)
        end

        it "sets the dqt_update_sha to the trainee sha" do
          expect {
            described_class.perform_now(trainee)
          }.to change(trainee, :dqt_update_sha).to(trainee_sha)
        end
      end
    end

    context "we don't receive an award date" do
      it "raises an error" do
        expect {
          described_class.perform_now(trainee)
        }.to raise_error(DqtNoAwardDateError)
      end
    end
  end
end
