# frozen_string_literal: true

require "rails_helper"

module Dttp
  describe RetrieveAward do
    describe "#call" do
      let(:placement_assignment_entity_id) { SecureRandom.uuid }
      let(:trainee) { create(:trainee, :recommended_for_award, placement_assignment_dttp_id: placement_assignment_entity_id) }
      let(:path) { "/dfe_placementassignments(#{placement_assignment_entity_id})?$select=dfe_qtsawardflag" }

      subject { described_class.call(trainee: trainee) }

      before do
        allow(AccessToken).to receive(:fetch).and_return("token")
        allow(Client).to receive(:get).with(path).and_return(dttp_response)
      end

      context "success response" do
        let(:dttp_response) { double(code: 200, body: { dfe_qtsawardflag: award_flag }.to_json) }

        context "QTS is awarded" do
          let(:award_flag) { true }

          it "returns the QTS flag" do
            expect(subject).to eq(award_flag)
          end
        end

        context "QTS is not awarded" do
          let(:award_flag) { false }

          it "returns the QTS flag" do
            expect(subject).to eq(award_flag)
          end
        end
      end

      context "HTTP error" do
        let(:status) { 400 }
        let(:body) { "error" }
        let(:headers) { { foo: "bar" } }
        let(:dttp_response) { double(code: status, body: body, headers: headers) }

        it "raises a HttpError error with the response body as the message" do
          expect(Client).to receive(:get).with(path).and_return(dttp_response)
          expect {
            subject
          }.to raise_error(Dttp::RetrieveAward::HttpError, "status: #{status}, body: #{body}, headers: #{headers}")
        end
      end
    end
  end
end
