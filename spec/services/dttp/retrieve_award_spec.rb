# frozen_string_literal: true

require "rails_helper"

module Dttp
  describe RetrieveAward do
    describe "#call" do
      let(:placement_assignment_entity_id) { SecureRandom.uuid }
      let(:trainee) { build(:trainee, :recommended_for_award, placement_assignment_dttp_id: placement_assignment_entity_id) }
      let(:path) { "/dfe_placementassignments(#{placement_assignment_entity_id})?$select=dfe_qtsawardflag,dfe_qtseytsawarddate" }
      let(:request_url) { "#{Settings.dttp.api_base_url}#{path}" }

      subject { described_class.call(trainee: trainee) }

      before do
        allow(AccessToken).to receive(:fetch)
        stub_request(:get, request_url).to_return(http_response)
      end

      context "success response" do
        let(:http_response) { { status: 200, body: response_body.to_json } }

        context "QTS is awarded" do
          let(:response_body) { { "dfe_qtsawardflag" => true, "dfe_qtseytsawarddate" => "2019-06-28T23:00:00Z" } }

          it "returns the QTS flag" do
            expect(subject).to eq(response_body)
          end
        end

        context "QTS is not awarded" do
          let(:response_body) { { "dfe_qtsawardflag" => false, "dfe_qtseytsawarddate" => nil } }

          it "returns the QTS flag" do
            expect(subject).to eq(response_body)
          end
        end
      end

      it_behaves_like "an http error handler"
    end
  end
end
