# frozen_string_literal: true

require "rails_helper"

module Dttp
  describe RetrieveAward do
    describe "#call" do
      let(:placement_assignment_entity_id) { SecureRandom.uuid }
      let(:trainee) { create(:trainee, :recommended_for_award, placement_assignment_dttp_id: placement_assignment_entity_id) }
      let(:path) { "/dfe_placementassignments(#{placement_assignment_entity_id})?$select=dfe_qtsawardflag" }
      let(:request_url) { "#{Settings.dttp.api_base_url}#{path}" }

      subject { described_class.call(trainee: trainee) }

      before do
        allow(AccessToken).to receive(:fetch)
        stub_request(:get, request_url).to_return(http_response)
      end

      context "success response" do
        let(:http_response) { { status: 200, body: { dfe_qtsawardflag: award_flag }.to_json } }

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

      it_behaves_like "an http error handler"
    end
  end
end
