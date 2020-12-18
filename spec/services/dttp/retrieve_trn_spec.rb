# frozen_string_literal: true

require "rails_helper"

module Dttp
  describe RetrieveTrn do
    describe "#call" do
      let(:contact_entity_id) { SecureRandom.uuid }
      let(:trainee) { create(:trainee, :submitted_for_trn, dttp_id: contact_entity_id) }
      let(:path) { "/contacts(#{contact_entity_id})?$select=dfe_trn" }
      let(:trn) { "trn number" }

      before do
        allow(AccessToken).to receive(:fetch).and_return("token")
        allow(Client).to receive(:get).with(path).and_return(dttp_response)
      end

      context "TRN is available" do
        let(:trn) { "trn number" }
        let(:dttp_response) { double(code: 200, body: { dfe_trn: trn }.to_json) }

        it "returns the TRN value" do
          expect(described_class.call(trainee: trainee)).to eq(trn)
        end
      end

      context "TRN is not available" do
        let(:dttp_response) { double(code: 200, body: { dfe_trn: nil }.to_json) }

        it "does not change the trainee record" do
          expect(described_class.call(trainee: trainee)).to be_nil
        end
      end

      context "HTTP error" do
        let(:dttp_response) { double(code: 400, body: "error") }

        it "raises a HttpError error with the response body as the message" do
          expect(Client).to receive(:get).with(path).and_return(dttp_response)
          expect {
            described_class.call(trainee: trainee)
          }.to raise_error(Dttp::RetrieveTrn::HttpError, dttp_response.body)
        end
      end
    end
  end
end
