# frozen_string_literal: true

require "rails_helper"

module Dttp
  describe UpdateDormancy do
    describe "#call" do
      let(:trainee) do
        create(:trainee, :trn_received, :with_dttp_dormancy)
      end

      let(:path) { "/dfe_dormantperiods(#{trainee.dormancy_dttp_id})" }
      let(:expected_params) { { test: "value" }.to_json }
      let(:request_url) { "#{Settings.dttp.api_base_url}#{path}" }

      before do
        enable_features(:persist_to_dttp)
        allow(AccessToken).to receive(:fetch).and_return("token")
        stub_request(:patch, request_url).to_return(http_response)
        allow(Params::Dormancy).to receive(:new).with(trainee: trainee)
          .and_return(double(to_json: expected_params))
      end

      subject { described_class.call(trainee: trainee) }

      context "success" do
        let(:http_response) { { status: 204 } }

        it "sends a PATCH request to set entity property 'dfe_dormantperiods'" do
          expect(Client).to receive(:patch).with(path, body: expected_params).and_call_original
          subject
        end
      end

      it_behaves_like "an http error handler"
    end
  end
end
