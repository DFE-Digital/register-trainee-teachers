# frozen_string_literal: true

require "rails_helper"

module Auditing
  describe TraineeAuditorJob do
    include ActiveJob::TestHelper

    let(:trainee) { create(:trainee, :trn_received) }
    let(:user) { build(:user) }
    let(:remote_address) { "127.0.0.1" }

    let(:audited_changes) do
      trainee.outcome_date = Date.yesterday
      trainee.state = :recommended_for_award
      trainee.recommended_for_award_at = Time.zone.now
      trainee.send(:audited_changes)
    end

    it "creates a trainee audit record" do
      expect(trainee).to receive(:write_audit).with(action: "update",
                                                    audited_changes: audited_changes,
                                                    remote_address: remote_address)

      described_class.perform_now(trainee, audited_changes, user, remote_address)
    end
  end
end
