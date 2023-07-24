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
    let(:expected_path) { "/v2/teachers/#{trainee.trn}/itt-outcome?slugId=#{trainee.slug}&birthDate=#{trainee.date_of_birth.iso8601}" }
    let(:json_body_params) { "JSON Donovan" }

    subject { described_class.call(trainee:) }

    describe "#call" do
      before do
        enable_features(:integrate_with_dqt)
        allow(Dqt::Client).to receive(:put).and_return(dqt_response)
        allow(Dqt::Params::Award).to receive(:new).with(trainee:).and_return(award_params = double)
        allow(award_params).to receive(:to_json).and_return(json_body_params)
      end

      it "returns the award date" do
        expect(subject).to eq(award_date)
      end

      it "makes the correct request" do
        expect(Dqt::Client).to receive(:put).with(
          expected_path,
          body: json_body_params,
        ).and_return(dqt_response)
        subject
      end
    end
  end
end
