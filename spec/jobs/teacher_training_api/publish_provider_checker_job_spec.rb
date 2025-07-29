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
        "provider_type" => "university",
        "region_code" => "london",
        "code" => "A01",
        "county" => "London",
        "name" => "University of BAT",
        "accredited_body" => true,
      }
    end
    let(:unaccredited_provider_record) do
      {
        "ukprn" => "87654321",
        "urn" => nil,
        "postcode" => "S1 1NO",
        "provider_type" => "lead_school",
        "region_code" => "london",
        "code" => "Z01",
        "county" => "London",
        "name" => "School of BAT",
        "accredited_body" => false,
      }
    end

    around do |example|
      Timecop.freeze(current_time) { example.run }
    end

    before do
      allow(TeacherTrainingApi::PublishProviderChecker).to receive(:call).and_return(result)
      allow(SlackNotifierService).to receive(:call).and_return(true)
    end

    it "generates the correct message and sends it to Slack" do
      described_class.perform_now
      expect(SlackNotifierService).to have_received(:call)
    end

    context "when there are no missing providers" do
      before do
        allow(result).to receive_messages(
          lead_partner_matches: [1, 2],
          provider_matches: [3],
          missing_accredited: [],
          missing_unaccredited: [],
          total_count: 3,
        )
      end

      it "sends a success message to Slack" do
        described_class.perform_now
        expect(SlackNotifierService).to have_received(:call).with(
          hash_including(
            message: include(
              "[test] Publish Provider Checker Results #{current_time.to_fs(:govuk_date_and_time)} for #{Settings.current_recruitment_cycle_year}",
              "Matching lead partners: 2",
              "Matching providers: 1",
              "Missing accredited providers: 0",
              "Missing unaccredited providers: 0",
              "Total: 3",
            ),
            icon_emoji: ":inky-the-octopus:",
          ),
        )
      end
    end

    context "when there is one missing provider" do
      before do
        allow(result).to receive_messages(
          lead_partner_matches: [1, 2],
          provider_matches: [3],
          missing_accredited: [provider_record],
          missing_unaccredited: [unaccredited_provider_record],
          total_count: 5,
        )
      end

      it "sends a success message to Slack" do
        described_class.perform_now
        expect(SlackNotifierService).to have_received(:call).with(
          hash_including(
            message: include(
              "[test] Publish Provider Checker Results #{current_time.to_fs(:govuk_date_and_time)} for #{Settings.current_recruitment_cycle_year}",
              "Matching lead partners: 2",
              "Matching providers: 1",
              "Missing accredited providers: 1",
              "  - University of BAT (A01), UKPRN 12345678",
              "Missing unaccredited providers: 1",
              "  - School of BAT (Z01), UKPRN 87654321",
              "Total: 5",
            ),
            icon_emoji: ":alert:",
          ),
        )
      end
    end
  end
end
