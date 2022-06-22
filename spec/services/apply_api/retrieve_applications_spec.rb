# frozen_string_literal: true

require "rails_helper"

module ApplyApi
  describe RetrieveApplications do
    let(:changed_since) { nil }
    let(:recruitment_cycle_year) { Settings.current_recruitment_cycle_year }
    let(:expected_path) { "/applications?recruitment_cycle_year=#{recruitment_cycle_year}&page=1" }
    let(:http_response) { { status: status, body: ApiStubs::ApplyApi.applications } }
    let(:request_url) { "#{Settings.apply_api.base_url}#{expected_path}" }

    subject { described_class.call(changed_since: changed_since, recruitment_cycle_year: recruitment_cycle_year).to_a }

    before do
      stub_request(:get, request_url).to_return(http_response)
    end

    describe "#call" do
      context "when the response is success" do
        let(:status) { 200 }

        context "when no 'changed_since' is provided" do
          it "logs the successful request" do
            expect { subject }.to change { ApplyApplicationSyncRequest.count }.by(1)
          end

          it "returns all the Apply applications" do
            expect(subject).to contain_exactly(ApiStubs::ApplyApi.application)
          end

          context "when there are no applications" do
            let(:http_response) { { status: status, body: { data: [] }.to_json } }

            it "returns empty array" do
              expect(subject.to_a).to eq([])
            end
          end
        end

        context "when there are multiple pages of results" do
          let(:http_response_page1) {
            {
              status: status,
              body: ApiStubs::ApplyApi.applications_page1,
              headers: {
                "Current-Page" => "1",
                "Page-Items" => "2",
                "Total-Pages" => "2",
                "Total-Count" => "3",
              },
            }
          }
          let(:http_response_page2) {
            {
              status: status,
              body: ApiStubs::ApplyApi.applications_page2,
              headers: {
                "Current-Page" => "2",
                "Page-Items" => "1",
                "Total-Pages" => "2",
                "Total-Count" => "3",
              },
            }
          }
          let(:expected_path_page2) { "/applications?recruitment_cycle_year=#{recruitment_cycle_year}&page=2" }
          let(:request_url_page2) { "#{Settings.apply_api.base_url}#{expected_path_page2}" }

          before do
            stub_request(:get, request_url).to_return(http_response_page1)
            stub_request(:get, request_url_page2).to_return(http_response_page2)
          end

          it "logs the successful request" do
            expect { subject }.to change { ApplyApplicationSyncRequest.count }.by(1)
          end

          it "returns all the Apply applications" do
            expect(subject).to contain_exactly(
              ApiStubs::ApplyApi.application(id: "3772"),
              ApiStubs::ApplyApi.application(id: "3773"),
              ApiStubs::ApplyApi.application(id: "3774"),
            )
          end
        end

        context "when a 'changed_at' is provided" do
          let(:changed_since) { Time.zone.now }
          let(:expected_query) { { recruitment_cycle_year: recruitment_cycle_year, changed_since: changed_since.utc.iso8601, page: "1" }.to_query }
          let(:expected_path) { "/applications?#{expected_query}" }

          it "includes the changed_at param in the request" do
            expect(ApplyApi::Client::Request).to receive(:get).with(expected_path).and_call_original
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
