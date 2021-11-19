# frozen_string_literal: true

require "rails_helper"

module ApplyApi
  describe ImportApplicationsJob do
    include ActiveJob::TestHelper

    let(:recruitment_cycle_year) { Time.zone.today.year }
    let(:application_data) { double("application_data") }
    let(:application_record) { double("application_record") }

    before do
      allow(RetrieveApplications).to receive(:call).and_return([application_data])
      allow(Settings.apply_applications.import).to receive(:recruitment_cycle_years).and_return([recruitment_cycle_year])
    end

    context "when the feature flag is turned on", feature_import_applications_from_apply: true do
      context "when a from_date param is given" do
        let(:from_date) { "2019-01-01" }

        it "calls the RetrieveApplications service with the from_date param" do
          expect(RetrieveApplications).to receive(:call).with(changed_since: from_date, recruitment_cycle_year: recruitment_cycle_year)
          expect(ImportApplication).to receive(:call).with(application_data: application_data).and_return(application_record)

          described_class.perform_now(from_date: from_date)
        end
      end

      context "when there have been no previous syncs" do
        it "imports application data from Apply and creates a trainee record" do
          expect(RetrieveApplications).to receive(:call).with(changed_since: nil, recruitment_cycle_year: recruitment_cycle_year)
          expect(ImportApplication).to receive(:call).with(application_data: application_data).and_return(application_record)

          described_class.perform_now
        end
      end

      context "when the last sync was successful" do
        let(:last_sync) { Time.zone.yesterday }

        before { create(:apply_application_sync_request, :successful, created_at: last_sync) }

        it "imports just the new applications from Apply" do
          expect(RetrieveApplications).to receive(:call).with(changed_since: last_sync, recruitment_cycle_year: recruitment_cycle_year)
          expect(ImportApplication).to receive(:call).with(application_data: application_data).and_return(application_record)

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
          expect(RetrieveApplications).to receive(:call).with(changed_since: last_successful_sync, recruitment_cycle_year: recruitment_cycle_year)
          expect(ImportApplication).to receive(:call).with(application_data: application_data).and_return(application_record)

          described_class.perform_now
        end
      end

      context "when ImportApplication returns ApplyApiMissingDataError" do
        before do
          allow(ImportApplication).to receive(:call).with(application_data: application_data).and_raise ApplyApi::ImportApplication::ApplyApiMissingDataError
        end

        it "is rescued and captured by Sentry" do
          expect(Sentry).to receive(:capture_exception).with(ApplyApi::ImportApplication::ApplyApiMissingDataError)
          described_class.perform_now
        end
      end
    end

    context "when the feature flag is turned off", feature_import_applications_from_apply: false do
      it "does nothing" do
        expect(RetrieveApplications).not_to receive(:call).with(changed_since: nil)
        expect(ImportApplication).not_to receive(:call).with(application_data: application_data)

        described_class.perform_now
      end
    end
  end
end
