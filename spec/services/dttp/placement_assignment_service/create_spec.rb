# frozen_string_literal: true

require "rails_helper"

module Dttp
  module PlacementAssignmentService
    describe Create do
      let(:trainee) { TraineePresenter.new(trainee: build(:trainee, :with_programme_details)) }
      let(:access_token) { "token" }
      let(:placementassignmentid) { SecureRandom.uuid }
      let(:endpoint_path) { "/dfe_placementassignments" }
      let(:headers) do
        {
          "odata-version" => "4.0",
          "odata-entityid" => "https://example.com/api/data/v9.0/dfe_placementassignments(#{placementassignmentid})",
        }
      end

      let(:response) { double(body: "", headers: headers) }

      before do
        allow(AccessTokenService).to receive(:call).and_return(access_token)
      end

      describe ".call" do
        context "with all valid information" do
          it "sends the payload to dttp" do
            expect(Client).to receive(:post).with(
                endpoint_path,
                hash_including(body: trainee.placement_assignment_params.to_json),
                ).and_return(response)

            described_class.call(trainee: trainee)
          end
        end
      end
    end
  end
end
