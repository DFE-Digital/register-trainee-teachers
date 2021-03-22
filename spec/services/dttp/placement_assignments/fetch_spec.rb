# frozen_string_literal: true

require "rails_helper"

module Dttp
  module PlacementAssignments
    describe Fetch do
      describe "#call" do
        let(:trainee) { create(:trainee, dttp_id: :with_placement_assignment) }
        let(:path) { "/dfe_placementassignments(#{trainee.placement_assignment_dttp_id})" }

        before do
          allow(AccessToken).to receive(:fetch).and_return("token")
          allow(Client).to receive(:get).with(path).and_return(dttp_response)
        end

        context "Placement Assignment sample are available" do
          let(:dttp_response) do
            double(code: 200, body: nil)
          end

          it "returns placement assignment JSON ruby hash" do
            expect(described_class.call(trainee: trainee)).to be_a(Dttp::PlacementAssignment)
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
              described_class.call(trainee: trainee)
            }.to raise_error(Dttp::PlacementAssignments::Fetch::HttpError, "status: #{status}, body: #{body}, headers: #{headers}")
          end
        end
      end
    end
  end
end
