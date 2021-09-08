# frozen_string_literal: true

require "rails_helper"

module Trainees
  describe CreateFromApplyJob do
    include ActiveJob::TestHelper
    let(:state) { :importable }
    let(:provider_code) { create(:provider, apply_sync_enabled: apply_sync_enabled) }
    let(:apply_application) { create(:apply_application, accredited_body_code: provider_code.code, state: state) }

    describe "#perform", feature_import_applications_from_apply: true do
      context "provider has opted in to import applications from Apply" do
        let(:apply_sync_enabled) { true }

        it "creates a trainee" do
          expect(CreateFromApply).to receive(:call).with(application: apply_application)

          described_class.perform_now
        end

        context "apply application is not importable" do
          let(:state) { :imported }

          it "does not create a trainee" do
            expect(CreateFromApply).not_to receive(:call).with(application: apply_application)

            described_class.perform_now
          end
        end
      end

      context "provider has opted out to import applications from Apply" do
        let(:apply_sync_enabled) { false }

        it "does not create a trainee" do
          expect(CreateFromApply).not_to receive(:call).with(application: apply_application)

          described_class.perform_now
        end
      end
    end
  end
end
