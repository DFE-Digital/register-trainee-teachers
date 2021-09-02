# frozen_string_literal: true

require "rails_helper"

module Trainees
  describe CreateFromApplyJob do
    include ActiveJob::TestHelper

    describe "#perform", feature_import_applications_from_apply: true do
      context "apply application is importable" do
        let(:apply_application) { create(:apply_application, :importable) }

        it "creates a trainee" do
          expect(CreateFromApply).to receive(:call).with(application: apply_application)

          described_class.perform_now
        end
      end

      context "apply application is not importable" do
        let(:apply_application) { create(:apply_application) }

        it "does not create a trainee" do
          expect(CreateFromApply).not_to receive(:call).with(application: apply_application)

          described_class.perform_now
        end
      end
    end
  end
end
