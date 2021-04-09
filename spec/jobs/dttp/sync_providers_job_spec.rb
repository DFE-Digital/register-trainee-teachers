# frozen_string_literal: true

require "rails_helper"

RSpec.describe Dttp::SyncProvidersJob, type: :job do
  include ActiveJob::TestHelper

  before do
    allow(Dttp::RetrieveProviders).to receive(:call).with(request_uri: request_uri).and_return(provider_list)
  end

  let(:provider_hash) { ApiStubs::Dttp::Provider.attributes }

  let(:request_uri) { nil }
  let(:provider_list) do
    {
      items: [provider_hash, provider_hash],
      meta: { next_page_url: "https://example.com" },
    }
  end

  subject { described_class.perform_now }

  it "enqueues job with the next_page_url" do
    expect {
      subject
    }.to have_enqueued_job(described_class).with("https://example.com")
  end

  it "calls Dttp::ImportProvider for each provider_hash" do
    expect(Dttp::ImportProvider).to receive(:call).with(provider_hash: provider_hash).twice
    subject
  end

  context "when next_page_url is not available" do
    let(:provider_list) do
      {
        items: [provider_hash],
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
