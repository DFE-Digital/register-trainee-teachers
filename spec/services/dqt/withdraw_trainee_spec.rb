# frozen_string_literal: true

require "rails_helper"

module Dqt
  describe WithdrawTrainee do
    let(:trainee) { create(:trainee, :withdrawn) }
    let(:dqt_response) {
      {
        "trn" => trainee.trn,
      }
    }
    let(:expected_path) { "/v2/teachers/#{trainee.trn}/itt-outcome?birthDate=#{trainee.date_of_birth.iso8601}" }
    let(:json_body_params) { "withdrawing bob" }

    subject { described_class.call(trainee: trainee) }

    describe "#call" do
      before do
        enable_features(:integrate_with_dqt)
        allow(Dqt::Client).to receive(:patch).and_return(dqt_response)
        allow(Dqt::Params::Withdrawal).to receive(:new).with(trainee: trainee).and_return(award_params = double)
        allow(award_params).to receive(:to_json).and_return(json_body_params)
      end

      it "makes the correct request" do
        expect(Dqt::Client).to receive(:patch).with(
          expected_path,
          body: json_body_params,
        ).and_return(dqt_response)
        subject
      end
    end
  end
end
