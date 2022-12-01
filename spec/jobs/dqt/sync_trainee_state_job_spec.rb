# frozen_string_literal: true

require "rails_helper"

module Dqt
  describe SyncTraineeStateJob do
    let!(:trainee) { create(:trainee) }

    before do
      allow(SyncState).to receive(:call)
    end

    it "calls the SyncState service", feature_integrate_with_dqt: true do
      described_class.perform_now(trainee)
      expect(SyncState).to have_received(:call).with(trainee:)
    end
  end
end
