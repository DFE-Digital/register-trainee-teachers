# frozen_string_literal: true

require "rails_helper"

describe DiscardInactiveUsersJob do
  include ActiveJob::TestHelper

  let(:cutoff) { Settings.user_clean_up.inactive_after_days.days.ago }

  let!(:inactive_user) { create(:user, last_signed_in_at: cutoff - 1.day) }
  let!(:active_user) { create(:user, last_signed_in_at: cutoff + 1.day) }
  let!(:never_signed_in_long_ago) { create(:user, last_signed_in_at: nil, created_at: cutoff - 1.day) }
  let!(:never_signed_in_recently) { create(:user, last_signed_in_at: nil, created_at: cutoff + 1.day) }
  let!(:inactive_system_admin) { create(:user, :system_admin, last_signed_in_at: cutoff - 1.day) }

  it "enqueues job" do
    expect {
      described_class.perform_later
    }.to have_enqueued_job
  end

  it "discards users who have not signed in since the cutoff" do
    described_class.perform_now

    expect(inactive_user.reload).to be_discarded
  end

  it "discards users who have never signed in and were created before the cutoff" do
    described_class.perform_now

    expect(never_signed_in_long_ago.reload).to be_discarded
  end

  it "keeps users who have signed in since the cutoff" do
    described_class.perform_now

    expect(active_user.reload).to be_kept
  end

  it "keeps users who have never signed in but were created after the cutoff" do
    described_class.perform_now

    expect(never_signed_in_recently.reload).to be_kept
  end

  it "keeps system admins" do
    described_class.perform_now

    expect(inactive_system_admin.reload).to be_kept
  end

  it "does not change users that were already discarded" do
    inactive_user.discard
    original_discarded_at = inactive_user.reload.discarded_at

    described_class.perform_now

    expect(inactive_user.reload.discarded_at).to eq(original_discarded_at)
  end
end
