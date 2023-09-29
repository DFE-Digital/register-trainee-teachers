# frozen_string_literal: true

require "rails_helper"

RSpec.describe BulkUpdate::AuditingJob do
  include ActiveJob::TestHelper

  let(:resource) { create(:trainee, :trn_received) }
  let(:user) { create(:user) }
  let(:remote_address) { "127.0.0.1" }
  let(:model) { Trainee }
  let(:id) { resource.id }

  let(:audited_changes) do
    {
      "state" => %w[draft recommended_for_award],
    }
  end

  let(:last_audit) { resource.audits.last }

  before do
    described_class.perform_now(
      model:,
      id:,
      audited_changes:,
      user:,
      remote_address:,
    )
  end

  it "triggers the auditing logic correctly" do
    expect(last_audit.audited_changes).to eq(audited_changes)
    expect(last_audit.remote_address).to eq(remote_address)
    expect(last_audit.user).to eq(user)
  end
end
