# frozen_string_literal: true

require "rails_helper"

describe SessionStoreTruncateJob do
  include ActiveJob::TestHelper

  context "with sessions" do
    let(:sessions) do
      create(:session, :recent_session)
      create(:session, :old_session)
    end

    before do
      sessions
    end

    it "enqueues job" do
      expect {
        described_class.perform_later
      }.to have_enqueued_job
    end

    it "should delete only old session" do
      expect(ActiveRecord::SessionStore::Session.count).to eq(2)
      described_class.perform_now
      expect(ActiveRecord::SessionStore::Session.count).to eq(1)
    end
  end
end
