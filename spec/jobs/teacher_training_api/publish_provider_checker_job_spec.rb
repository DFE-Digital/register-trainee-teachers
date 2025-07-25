# frozen_string_literal: true

require "rails_helper"

module TeacherTrainingApi
  describe PublishProviderCheckerJob do
    include ActiveJob::TestHelper

    let(:recruitment_cycle_year) { Settings.current_recruitment_cycle_year }
    let(:result) { TeacherTrainingApi::PublishProviderChecker.send(:new, recruitment_cycle_year:) }
    let(:current_time) { Time.zone.now }

    let(:provider_record) do
      {
        "ukprn" => "12345678",
        "urn" => nil,
        "postcode" => "N1 1NO",
        "provider_type" => "hei",
        "region_code" => "london",
        "code" => "A01",
        "county" => "London",
        "name" => "University of BAT",
      }
    end

    around do |example|
      Timecop.freeze(current_time) { example.run }
    end

    before do
      allow(TeacherTrainingApi::PublishProviderChecker).to receive(:call).and_return(result)
      allow(SlackNotifierService).to receive(:call).and_return(true)
    end

    context "when the feature flag is turned off", feature_publish_provider_checker: false do
      it "does not call TTAPI or Slack" do
        described_class.perform_now
        expect(SlackNotifierService).not_to have_received(:call)
      end
    end

    context "when the feature flag is turned on", feature_publish_provider_checker: true do
      it "generates the correct message and sends it to Slack" do
        described_class.perform_now
        expect(SlackNotifierService).to have_received(:call)
      end

      context "when there are no missing providers" do
        before do
          allow(result).to receive_messages(
            school_matches: [1, 2, 3],
            lead_partner_matches: [4, 5],
            provider_matches: [6],
            missing: [],
            total_count: 6,
          )
        end

        it "sends a success message to Slack" do
          described_class.perform_now
          expect(SlackNotifierService).to have_received(:call).with(
            hash_including(
              message: include(
                "[test] Publish Provider Checker Results #{current_time.to_fs(:govuk_date_and_time)} for #{Settings.current_recruitment_cycle_year}",
                "Matching lead schools: 3",
                "Matching lead schools: 3",
                "Matching lead partners: 2",
                "Matching providers: 1",
                "Missing providers: 0",
                "Total: 6",
              ),
              icon_emoji: ":inky-the-octopus:",
            ),
          )
        end
      end

      context "when there is one missing provider" do
        before do
          allow(result).to receive_messages(
            school_matches: [1, 2, 3],
            lead_partner_matches: [4, 5],
            provider_matches: [6],
            missing: [provider_record],
            total_count: 7,
          )
        end

        it "sends a success message to Slack" do
          described_class.perform_now
          expect(SlackNotifierService).to have_received(:call).with(
            hash_including(
              message: include(
                "[test] Publish Provider Checker Results #{current_time.to_fs(:govuk_date_and_time)} for #{Settings.current_recruitment_cycle_year}",
                "Matching lead schools: 3",
                "Matching lead schools: 3",
                "Matching lead partners: 2",
                "Matching providers: 1",
                "Missing providers: 1",
                "  - University of BAT (A01), UKPRN 12345678",
                "Total: 7",
              ),
              icon_emoji: ":alert:",
            ),
          )
        end
      end
    end
  end
end
