# frozen_string_literal: true

require "rails_helper"

module Dttp
  module Contact
    describe Create do
      let(:trainee) { TraineePresenter.new(trainee: build(:trainee)) }
      let(:access_token) { "token" }
      let(:endpoint_path) { "/contacts" }
      let(:contactid) { SecureRandom.uuid }
      let(:dttp_response_headers) do
        {
          "odata-version" => "4.0",
          "odata-entityid" => "https://example.com/api/data/v9.0/#{endpoint_path}(#{contactid})",
        }
      end

      let(:dttp_client_response) { double(body: "", headers: dttp_response_headers) }

      before do
        allow(AccessToken).to receive(:fetch).and_return(access_token)
        allow(trainee).to receive(:update!)
      end

      describe ".call" do
        it "sends a POST request to DTTP with all the necessary contact parmeters" do
          body = { body: trainee.contact_params.to_json }

          expect(Client).to receive(:post).with(endpoint_path, hash_including(body)).and_return(dttp_client_response)

          described_class.call(trainee: trainee)
        end

        it "stores the returned contact ID in the trainee dttp_id column" do
          allow(Client).to receive(:post).and_return(dttp_client_response)

          expect(trainee).to receive(:update!).with(dttp_id: contactid)

          described_class.call(trainee: trainee)
        end
      end
    end
  end
end
