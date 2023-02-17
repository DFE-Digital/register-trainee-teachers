# frozen_string_literal: true

require "rails_helper"

module Dqt
  describe SyncTeacherJob do
    let!(:trainee) { create(:trainee) }

    before do
      allow(SyncTeacher).to receive(:call)
      enable_features("dqt_import.sync_teachers")
    end

    it "calls the SyncTeacher service" do
      described_class.perform_now(trainee)
      expect(SyncTeacher).to have_received(:call).with(trainee:)
    end
  end
end
