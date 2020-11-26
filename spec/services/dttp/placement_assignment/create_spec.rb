# frozen_string_literal: true

require "rails_helper"

module Dttp
  module PlacementAssignment
    describe Create do
      let(:trainee) { TraineePresenter.new(trainee: create(:trainee, :with_programme_details)) }
      let(:degree) { create(:degree, :uk_degree_with_details) }
      let(:access_token) { "token" }
      let(:endpoint_path) { "/dfe_placementassignments" }
      let(:placementassignmentid) { SecureRandom.uuid }
      let(:dttp_response_headers) do
        {
          "odata-version" => "4.0",
          "odata-entityid" => "https://example.com/api/data/v9.0/#{endpoint_path}(#{placementassignmentid})",
        }
      end

      let(:dttp_client_response) { double(body: "", headers: dttp_response_headers) }

      before do
        allow(AccessToken).to receive(:fetch).and_return(access_token)
        allow(trainee).to receive(:update!)
      end

      describe ".call" do
        before do
          trainee.degrees << degree
        end

        it "sends a POST request to DTTP with all the necessary placement assignment parameters" do
          body = { body: trainee.placement_assignment_params.to_json }

          expect(Client).to receive(:post).with(endpoint_path, hash_including(body)).and_return(dttp_client_response)

          described_class.call(trainee: trainee)
        end
      end
    end
  end
end
