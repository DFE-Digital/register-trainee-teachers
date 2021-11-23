# frozen_string_literal: true

require "rails_helper"

module ApplyApi
  describe RetrieveApplications do
    let(:changed_since) { nil }
    let(:recruitment_cycle_year) { Settings.current_recruitment_cycle_year }
    let(:expected_path) { "/applications?recruitment_cycle_year=#{recruitment_cycle_year}" }
    let(:http_response) { { status: status, body: ApiStubs::ApplyApi.applications } }
    let(:request_url) { "#{Settings.apply_api.base_url}#{expected_path}" }

    subject { described_class.call(changed_since: changed_since, recruitment_cycle_year: recruitment_cycle_year) }

    before do
      stub_request(:get, request_url).to_return(http_response)
    end

    describe "#call" do
      context "when the response is success" do
        let(:status) { 200 }

        context "when no 'changed_since' is provided" do
          it "logs the successful request" do
            subject
            request = ApplyApplicationSyncRequest.last
            expect(request).to be_successful
            expect(request.response_code).to eq status
          end

          it "returns all the Apply applications" do
            expect(subject).to contain_exactly(ApiStubs::ApplyApi.application)
          end

          context "when there are no applications" do
            let(:http_response) { { status: status, body: { data: [] }.to_json } }

            it "returns empty array" do
              expect(subject).to eq []
            end
          end
        end

        context "when a 'changed_at' is provided" do
          let(:changed_since) { Time.zone.now }
          let(:expected_query) { { recruitment_cycle_year: recruitment_cycle_year, changed_since: changed_since.utc.iso8601 }.to_query }
          let(:expected_path) { "/applications?#{expected_query}" }

          it "includes the changed_at param in the request" do
            expect(Client).to receive(:get).with(expected_path).and_call_original
            subject
          end
        end
      end

      it_behaves_like "an http error handler" do
        it "logs the unsuccessful response" do
          expect {
            subject
          }.to raise_error(Client::HttpError)
          request = ApplyApplicationSyncRequest.last
          expect(request).not_to be_successful
          expect(request.response_code).to eq status
        end
      end
    end
  end
end
