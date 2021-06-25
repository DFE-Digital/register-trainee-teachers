# frozen_string_literal: true

require "rails_helper"

RSpec.describe Dttp::SyncProvidersJob, type: :job do
  include ActiveJob::TestHelper

  before do
    enable_features(:sync_from_dttp)
    allow(Dttp::RetrieveProviders).to receive(:call).with(request_uri: request_uri).and_return(provider_list)
  end

  let(:provider_one_hash) { create(:api_provider) }
  let(:provider_two_hash) { create(:api_provider) }

  let(:request_uri) { nil }
  let(:provider_list) do
    {
      items: [provider_two_hash, provider_one_hash],
      meta: { next_page_url: "https://example.com" },
    }
  end

  subject { described_class.perform_now }

  it "enqueues job with the next_page_url" do
    expect {
      subject
    }.to have_enqueued_job(described_class).with("https://example.com")
  end

  it "creates a Dttp::Provider record for each unique provider" do
    expect {
      subject
    }.to change(Dttp::Provider, :count).by(2)
  end

  context "when Dttp::Provider exist" do
    let!(:dttp_provider_one) { create(:dttp_provider, dttp_id: provider_one_hash["accountid"]) }

    it "adds new records" do
      expect {
        subject
      }.to change(Dttp::Provider, :count).by(1)
    end

    it "updates the existing record" do
      subject
      expect(dttp_provider_one.reload.name).to eq(provider_one_hash["name"])
    end
  end

  context "when next_page_url is not available" do
    let(:provider_list) do
      {
        items: [provider_one_hash],
        meta: { next_page_url: nil },
      }
    end

    it "does not enqueue any further jobs" do
      expect {
        subject
      }.not_to have_enqueued_job(described_class)
    end
  end
end
