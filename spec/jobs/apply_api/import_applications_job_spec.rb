# frozen_string_literal: true

require "rails_helper"

module ApplyApi
  describe ImportApplicationsJob do
    include ActiveJob::TestHelper

    let(:application_data) { double("application_data") }
    let(:application_record) { double("application_record") }

    before do
      allow(RetrieveApplications).to receive(:call).and_return([application_data])
    end

    context "when the feature flag is turned on", feature_import_applications_from_apply: true do
      context "when there have been no previous syncs" do
        it "imports application data from Apply and creates a trainee record" do
          expect(RetrieveApplications).to receive(:call).with(changed_since: nil)
          expect(ImportApplication).to receive(:call).with(application_data: application_data).and_return(application_record)
          expect(Trainees::CreateFromApply).to receive(:call).with(application: application_record)

          described_class.perform_now
        end
      end

      context "when the last sync was successful" do
        let(:last_sync) { Time.zone.yesterday }

        before { create(:apply_application_sync_request, :successful, created_at: last_sync) }

        it "imports just the new applications from Apply" do
          expect(RetrieveApplications).to receive(:call).with(changed_since: last_sync)
          expect(ImportApplication).to receive(:call).with(application_data: application_data).and_return(application_record)
          expect(Trainees::CreateFromApply).to receive(:call).with(application: application_record)

          described_class.perform_now
        end
      end

      context "when the last sync was unsuccessful" do
        let(:last_successful_sync) { Time.zone.yesterday }
        let(:last_sync) { Time.zone.today }

        before do
          create(:apply_application_sync_request, :successful, created_at: last_successful_sync)
          create(:apply_application_sync_request, :unsuccessful, created_at: last_sync)
        end

        it "imports just the new applications from Apply" do
          expect(RetrieveApplications).to receive(:call).with(changed_since: last_successful_sync)
          expect(ImportApplication).to receive(:call).with(application_data: application_data).and_return(application_record)
          expect(Trainees::CreateFromApply).to receive(:call).with(application: application_record)

          described_class.perform_now
        end
      end
    end

    context "when the feature flag is turned off", feature_import_applications_from_apply: false do
      it "does nothing" do
        expect(RetrieveApplications).not_to receive(:call).with(changed_since: nil)
        expect(ImportApplication).not_to receive(:call).with(application_data: application_data)
        expect(Trainees::CreateFromApply).not_to receive(:call).with(application: application_record)

        described_class.perform_now
      end
    end
  end
end
