# frozen_string_literal: true

require "rails_helper"

module Dttp
  describe RetrieveTrn do
    describe "#call" do
      let(:contact_entity_id) { SecureRandom.uuid }
      let(:trainee) { create(:trainee, :submitted_for_trn, dttp_id: contact_entity_id) }
      let(:path) { "/contacts(#{contact_entity_id})?$select=dfe_trn" }
      let(:trn) { "trn number" }
      let(:request_url) { "#{Settings.dttp.api_base_url}#{path}" }

      before do
        allow(AccessToken).to receive(:fetch).and_return("token")
        stub_request(:get, request_url).to_return(http_response)
      end

      subject { described_class.call(trainee: trainee) }

      context "TRN is available" do
        let(:trn) { "trn number" }
        let(:http_response) { { status: 200, body: { dfe_trn: trn }.to_json } }

        it "returns the TRN value" do
          expect(subject).to eq(trn)
        end
      end

      context "TRN is not available" do
        let(:http_response) { { status: 200, body: { dfe_trn: nil }.to_json } }

        it "does not change the trainee record" do
          expect(subject).to be_nil
        end
      end

      it_behaves_like "an http error handler"
    end
  end
end
