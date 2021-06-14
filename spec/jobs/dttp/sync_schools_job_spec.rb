# frozen_string_literal: true

require "rails_helper"

RSpec.describe Dttp::SyncSchoolsJob, type: :job do
  include ActiveJob::TestHelper

  before do
    enable_features(:sync_from_dttp)
    allow(Dttp::RetrieveSchools).to receive(:call).with(request_uri: request_uri).and_return(school_list)
  end

  let(:school_one_hash) { ApiStubs::Dttp::School.attributes }
  let(:school_two_hash) { ApiStubs::Dttp::School.attributes }

  let(:request_uri) { nil }
  let(:school_list) do
    {
      items: [school_two_hash, school_one_hash],
      meta: { next_page_url: "https://example.com" },
    }
  end

  subject { described_class.perform_now }

  it "enqueues job with the next_page_url" do
    expect {
      subject
    }.to have_enqueued_job(described_class).with("https://example.com")
  end

  it "creates a Dttp::School record for each unique school" do
    expect {
      subject
    }.to change(Dttp::School, :count).by(2)
  end

  context "when Dttp::School exist" do
    let!(:dttp_school_one) { create(:dttp_school, name: "Westminster School", dttp_id: school_one_hash["accountid"]) }

    it "adds new records" do
      expect {
        subject
      }.to change(Dttp::School, :count).by(1)
    end

    it "updates the existing record" do
      expect { subject }.to change { dttp_school_one.reload.name }.from("Westminster School").to("Test School")
    end
  end

  context "when next_page_url is not available" do
    let(:school_list) do
      {
        items: [school_one_hash],
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
