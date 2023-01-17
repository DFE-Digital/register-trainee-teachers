# frozen_string_literal: true

require "rails_helper"

module Hesa
  describe SyncStudentsJob do
    context "feature flag is off" do
      before { disable_features("hesa_import.sync_collection") }

      it "doesn't call the HESA API" do
        expect(Hesa::SyncStudents).not_to receive(:call)
        described_class.new.perform
      end
    end

    context "feature flag is on" do
      before { enable_features("hesa_import.sync_collection") }

      it "calls the HESA API" do
        expect(Hesa::SyncStudents).to receive(:call)
        described_class.new.perform
      end
    end
  end
end
