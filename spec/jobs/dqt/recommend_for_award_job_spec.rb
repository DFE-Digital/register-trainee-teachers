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
    end

    context "we don't receive an award date" do
      it "raises an error" do
        expect {
          described_class.perform_now(trainee)
        }.to raise_error(DqtNoAwardDateError)
      end
    end

    context "with a HESA trainee" do
      before do
        allow(trainee).to receive(:hesa_record?).and_return(true)
      end

      it "reports to Slack" do
        expect(SlackNotifierService).to receive(:call).with(message: "Trainee id: #{trainee.id}, slug: #{trainee.slug} has been recommended for award but is a HESA trainee", username: "Register Trainee Teachers: Job Failure")
        described_class.perform_now(trainee)
      end

      it "doesn't send the trainee to DQT" do
        expect(RecommendForAward).not_to receive(:call)
        described_class.perform_now(trainee)
      end
    end
  end
end
