# frozen_string_literal: true

require "rails_helper"

module ApplyApi
  describe RetrieveApplications do
    let(:changed_since) { nil }
    let(:expected_url) { "/applications?recruitment_cycle_year=2021" }
    let(:response) { double(code: code, body: ApiStubs::ApplyApi.applications) }

    subject { described_class.call(changed_since: changed_since) }

    before do
      allow(Client).to receive(:get).with(expected_url).and_return(response)
    end

    describe "#call" do
      context "when the response is success" do
        let(:code) { 200 }

        context "when no 'changed_since' is provided" do
          before do
            allow(Client).to receive(:get).with(expected_url).and_return(response)
          end

          it "logs the successful request" do
            subject
            request = ApplyApplicationSyncRequest.last
            expect(request).to be_successful
            expect(request.response_code).to eq code
          end

          it "returns all the Apply applications" do
            expect(subject).to contain_exactly(ApiStubs::ApplyApi.application)
          end

          context "when there are no applications" do
            let(:response) { double(code: code, body: { data: [] }.to_json) }

            it "returns empty array" do
              expect(subject).to eq []
            end
          end
        end

        context "when a 'changed_at' is provided" do
          let(:changed_since) { Time.zone.now }
          let(:expected_query) { { recruitment_cycle_year: 2021, changed_since: changed_since }.to_query }
          let(:expected_url) { "/applications?#{expected_query}" }

          it "includes the changed_at param in the request" do
            expect(Client).to receive(:get).with(expected_url)
            subject
          end
        end
      end

      context "when the response is error" do
        let(:code) { 500 }
        let(:body) { "error" }
        let(:headers) { { foo: "bar" } }
        let(:response) { double(code: code, body: body, headers: headers) }

        it "raises a HttpError error and logs the unsuccessful response" do
          expect {
            subject
          }.to raise_error(ApplyApi::RetrieveApplications::HttpError, "status: #{code}, body: #{body}, headers: #{headers}")

          request = ApplyApplicationSyncRequest.last
          expect(request).not_to be_successful
          expect(request.response_code).to eq code
        end
      end
    end
  end
end
