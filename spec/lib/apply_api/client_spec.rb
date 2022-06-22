# frozen_string_literal: true

require "rails_helper"

module ApplyApi
  describe Client do
    let(:recruitment_cycle_year) { Settings.current_recruitment_cycle_year }
    let(:expected_path) { "/applications?recruitment_cycle_year=#{recruitment_cycle_year}" }
    let(:http_response) { { status: 200, body: ApiStubs::ApplyApi.applications } }
    let(:request_url) { "#{Settings.apply_api.base_url}#{expected_path}" }

    subject { described_class.get(changed_since: nil, recruitment_cycle_year: recruitment_cycle_year) }

    before do
      stub_request(:get, request_url).to_return(http_response)
    end

    it "calls API with correct URL" do
      expect(ApplyApi::Client::Request).to receive(:get).with(expected_path).and_call_original
      subject
    end

    it "creates an ApplyApplicationSyncRequest record with recruitment_cycle_year" do
      expect { subject }.to(
        change { ApplyApplicationSyncRequest.successful.where(recruitment_cycle_year: recruitment_cycle_year).count }.by(1),
      )
    end
  end
end
