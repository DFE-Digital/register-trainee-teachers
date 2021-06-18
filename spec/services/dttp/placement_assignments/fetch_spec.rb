# frozen_string_literal: true

require "rails_helper"

module Dttp
  module PlacementAssignments
    describe Fetch do
      describe "#call" do
        let(:placement_assignment_dttp_id) { SecureRandom.uuid }
        let(:path) { "/dfe_placementassignments(#{placement_assignment_dttp_id})" }
        let(:request_url) { "#{Settings.dttp.api_base_url}#{path}" }

        before do
          allow(AccessToken).to receive(:fetch)
          stub_request(:get, request_url).to_return(http_response)
        end

        subject { described_class.call(dttp_id: placement_assignment_dttp_id) }

        context "Placement Assignment sample are available" do
          let(:http_response) do
            { status: 200, body: {}.to_json }
          end

          it "returns placement assignment JSON ruby hash" do
            expect(subject).to be_a(Dttp::PlacementAssignment)
          end
        end

        it_behaves_like "an http error handler" do
          let(:expected_error) { Client::HttpError }
        end
      end
    end
  end
end
