# frozen_string_literal: true

RSpec.shared_examples "dttp trainee update" do |dttp_param_processor|
  let(:trainee) do
    create(:trainee, :trn_received, outcome_date: outcome_date, placement_assignment_dttp_id: placement_assignment_dttp_id)
  end

  let(:outcome_date) { Faker::Date.in_date_period }
  let(:placement_assignment_dttp_id) { SecureRandom.uuid }
  let(:path) { "/dfe_placementassignments(#{placement_assignment_dttp_id})" }
  let(:expected_params) { { test: "value" }.to_json }
  let(:request_url) { "#{Settings.dttp.api_base_url}#{path}" }

  before do
    enable_features(:persist_to_dttp)
    allow(Dttp::AccessToken).to receive(:fetch).and_return("token")
    stub_request(:patch, request_url).to_return(http_response)
    allow(dttp_param_processor)
      .to receive(:new).with(trainee: trainee)
      .and_return(double(to_json: expected_params))
  end

  subject { described_class.call(trainee: trainee) }

  context "success" do
    let(:http_response) { { status: 204 } }

    it_behaves_like "CreateOrUpdateConsistencyCheckJob", described_class

    it "sends a PATCH request to set entity property 'dfe_datestandardsassessmentpassed'" do
      expect(Dttp::Client).to receive(:patch).with(path, body: expected_params).and_call_original
      subject
    end
  end

  it_behaves_like "an http error handler" do
    it "does not enqueue the CreateOrUpdateConsistencyCheckJob" do
      allow(Dttp::Client).to receive(:patch).with(path, body: expected_params).and_return(instance_double("HTTParty::Response", success?: false))
      ActiveJob::Base.queue_adapter = :test

      subject
      expect(CreateOrUpdateConsistencyCheckJob).not_to have_been_enqueued
    end
  end
end
