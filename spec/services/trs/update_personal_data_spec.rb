# frozen_string_literal: true

require "rails_helper"

module Trs
  describe UpdatePersonalData do
    describe "#call" do
      let(:trainee) { create(:trainee, :trn_received) }
      let(:expected_path) { "/v3/persons/#{trainee.trn}" }
      let(:response) { {} }

      before do
        enable_features(:integrate_with_trs)
        allow(Trs::Client).to receive(:put).and_return(response)
      end

      context "when integrate_with_trs is disabled" do
        before do
          disable_features(:integrate_with_trs)
        end

        it "does not call the TRS API" do
          described_class.call(trainee:)
          expect(Trs::Client).not_to have_received(:put)
        end
      end

      context "when trainee is in an invalid state" do
        let(:trainee) { create(:trainee, :withdrawn) }

        it "does not call the TRS API" do
          described_class.call(trainee:)
          expect(Trs::Client).not_to have_received(:put)
        end
      end

      context "when trainee does not have a TRN" do
        let(:trainee) { create(:trainee, :trn_received, trn: nil) }

        it "raises an error" do
          expect {
            described_class.call(trainee:)
          }.to raise_error(described_class::PersonUpdateMissingTrn)
        end
      end

      context "when trainee has all required fields" do
        it "calls the TRS API with the correct parameters" do
          payload = instance_double(Trs::Params::PersonalData, to_json: '{"test": "data"}')
          allow(Trs::Params::PersonalData).to receive(:new).with(trainee:).and_return(payload)

          described_class.call(trainee:)

          expect(Trs::Client).to have_received(:put).with(
            expected_path,
            body: payload.to_json,
          )
        end
      end

      context "when TRS Client raises an error" do
        before do
          allow(Trs::Client).to receive(:put).and_raise(
            Trs::Client::HttpError.new("status: 500, body: Server error, headers: {}"),
          )
        end

        it "raises a PersonUpdateError" do
          expect {
            described_class.call(trainee:)
          }.to raise_error(described_class::PersonUpdateError)
        end
      end

      context "when TRS returns error code 10042 (PII updates not permitted)" do
        let(:error_body) do
          {
            title: "Updates to PII data is not permitted. Person has QTS.",
            status: 400,
            detail: "",
            errorCode: 10042,
          }.to_json
        end

        before do
          allow(Trs::Client).to receive(:put).and_raise(
            Trs::Client::HttpError.new("status: 400, body: #{error_body}, headers: {}"),
          )
        end

        it "completes successfully without raising an error" do
          expect {
            described_class.call(trainee:)
          }.not_to raise_error
        end
      end

      context "when TRS returns a different error code" do
        let(:error_body) do
          {
            title: "Bad Request",
            status: 400,
            detail: "Invalid data",
            errorCode: 12345,
          }.to_json
        end

        before do
          allow(Trs::Client).to receive(:put).and_raise(
            Trs::Client::HttpError.new("status: 400, body: #{error_body}, headers: {}"),
          )
        end

        it "raises a PersonUpdateError" do
          expect {
            described_class.call(trainee:)
          }.to raise_error(described_class::PersonUpdateError)
        end
      end
    end
  end
end
