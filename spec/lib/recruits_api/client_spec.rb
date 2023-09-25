# frozen_string_literal: true

require "rails_helper"

module RecruitsApi
  describe Client do
    let(:recruitment_cycle_year) { Settings.current_recruitment_cycle_year }
    let(:expected_path) { "/applications?recruitment_cycle_year=#{recruitment_cycle_year}" }
    let(:http_response) { { status: 200, body: ApiStubs::ApplyApi.applications } }
    let(:request_url) { "#{Settings.recruits_api.base_url}#{expected_path}" }

    subject { described_class.get(changed_since: nil, recruitment_cycle_year: recruitment_cycle_year) }

    before do
      stub_request(:get, request_url).to_return(http_response)
    end

    it "calls API with correct URL" do
      expect(ApplyApi::Client::Request).to receive(:get).with(expected_path).and_call_original
      subject
    end

    context "when the API call is successful" do
      it "does not create an ApplyApplicationSyncRequest record with recruitment_cycle_year" do
        expect { subject }.not_to(
          change { ApplyApplicationSyncRequest.where(recruitment_cycle_year:).count },
        )
      end
    end

    context "when the API call fails" do
      let(:http_response) { { status: 500, body: "Oops..." } }

      it "raises an HttpError" do
        expect { subject }.to raise_error(ApplyApi::Client::HttpError)
      end

      it "creates an unsuccessful ApplyApplicationSyncRequest record with recruitment_cycle_year" do
        expect do
          subject
        rescue ApplyApi::Client::HttpError
          # Suppress exception so that we can assert no `ApplyApplicationSyncRequest` is created.
        end.to change { ApplyApplicationSyncRequest.unsuccessful.where(recruitment_cycle_year:).count }.by(1)
      end
    end
  end
end
