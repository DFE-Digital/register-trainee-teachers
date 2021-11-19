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

        context "application is not for current cycle" do
          let(:apply_application) do
            create(:apply_application,
                   accredited_body_code: provider_code.code,
                   state: state,
                   recruitment_cycle_year: Settings.apply_applications.create.recruitment_cycle_year + 1)
          end

          it "does not create a trainee" do
            expect(CreateFromApply).not_to receive(:call).with(application: apply_application)

            described_class.perform_now
          end
        end

        context "apply application is not importable" do
          let(:state) { :imported }

          it "does not create a trainee" do
            expect(CreateFromApply).not_to receive(:call).with(application: apply_application)

            described_class.perform_now
          end
        end

        context "when CreateFromApply returns MissingCourseError" do
          before do
            allow(CreateFromApply).to receive(:call).with(application: apply_application).and_raise Trainees::CreateFromApply::MissingCourseError
          end

          it "is rescued and captured by Sentry" do
            expect(Sentry).to receive(:capture_exception).with(Trainees::CreateFromApply::MissingCourseError)
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
