# frozen_string_literal: true

require "rails_helper"

module Support
  describe DqtHelper do
    include DqtHelper

    describe "#formatted_dqt_trn_response" do
      let(:response) { nil }

      context "when `response` is nil" do
        it "returns nil" do
          expect(helper.formatted_dqt_trn_response(response)).to be_nil
        end
      end

      context "when `response` is error in correct format" do
        let(:response) do
          {
            "error" => "status: 404, body: {\"message\"=>\"Not Found\"}, headers: {\"Content-Type\"=>\"application/json\"}",
          }
        end

        it "returns formatted error" do
          expect(helper.formatted_dqt_trn_response(response)).to eq(
            JSON.pretty_generate({
              error: {
                status: 404,
                body: { "message" => "Not Found" },
                headers: { "Content-Type" => "application/json" },
              },
            }),
          )
        end
      end

      context "when `response` is error in incorrect format" do
        let(:response) do
          {
            "error" => "status: 404, some_other_key: {}",
          }
        end

        it "returns formatted error" do
          expect(helper.formatted_dqt_trn_response(response)).to eq(
            JSON.pretty_generate({
              error: {
                status: 404,
                body: {},
                headers: {},
              },
            }),
          )
        end
      end
    end
  end
end
