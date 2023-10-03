# frozen_string_literal: true

require "rails_helper"

RSpec.describe BulkUpdate::UpsertAll, type: :service do
  let!(:trainee) { create(:trainee) }

  let(:original) do
    { trainee.id => {
      id: trainee.id,
      first_names: "John",
      state: trainee.state.to_sym,
      slug: trainee.slug,
      provider_id: trainee.provider_id,
    } }.with_indifferent_access
  end

  let(:modified) do
    { trainee.id => {
      id: trainee.id,
      first_names: "Johnny",
      state: :recommended_for_award,
      slug: trainee.slug,
      provider_id: trainee.provider_id,
    } }.with_indifferent_access
  end

  let(:expected_changes) { { first_names: %w[John Johnny], state: [0, 3] } }

  before do
    allow(BulkUpdate::AuditingJob).to receive(:perform_later)
    allow(BulkUpdate::AnalyticsJob).to receive(:perform_later)

    described_class.call(
      original: original,
      modified: modified,
      model: Trainee,
      unique_by: :slug,
    )
  end

  describe ".call" do
    it "upserts the records correctly" do
      expect(trainee.reload.first_names).to eq("Johnny")
      expect(trainee.state.to_sym).to eq(:recommended_for_award)
    end

    it "passes the correct attributes to the audit jobs" do
      expect(BulkUpdate::AuditingJob).to have_received(:perform_later).with(
        hash_including(
          model: Trainee,
          id: trainee.id,
          audited_changes: expected_changes,
        ),
      ).once
    end

    it "passes the trainee record to enqueue_analytics_job" do
      expect(BulkUpdate::AnalyticsJob).to have_received(:perform_later).with(
        model: Trainee, ids: [trainee.id],
      ).once
    end
  end
end
