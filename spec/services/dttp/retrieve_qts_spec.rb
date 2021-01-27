# frozen_string_literal: true

require "rails_helper"

module Dttp
  describe RetrieveQts do
    describe "#call" do
      let(:contact_entity_id) { SecureRandom.uuid }
      let(:trainee) { create(:trainee, :recommended_for_qts, dttp_id: contact_entity_id) }
      let(:path) { "/contacts(#{contact_entity_id})?$select=dfe_qtsawardflag" }

      subject { described_class.call(trainee: trainee) }

      before do
        allow(AccessToken).to receive(:fetch).and_return("token")
        allow(Client).to receive(:get).with(path).and_return(dttp_response)
      end

      context "success response" do
        let(:dttp_response) { double(code: 200, body: { dfe_qtsawardflag: qts_flag }.to_json) }

        context "QTS is awarded" do
          let(:qts_flag) { true }

          it "returns the QTS flag" do
            expect(subject).to eq(qts_flag)
          end
        end

        context "QTS is not awarded" do
          let(:qts_flag) { false }

          it "returns the QTS flag" do
            expect(subject).to eq(qts_flag)
          end
        end
      end

      context "HTTP error" do
        let(:dttp_response) { double(code: 400, body: "error") }

        it "raises a HttpError error with the response body as the message" do
          expect(Client).to receive(:get).with(path).and_return(dttp_response)
          expect {
            subject
          }.to raise_error(Dttp::RetrieveQts::HttpError, dttp_response.body)
        end
      end
    end
  end
end
