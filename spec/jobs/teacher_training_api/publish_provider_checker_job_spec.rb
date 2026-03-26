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
      allow(TeamsNotifierService).to receive(:call).and_return(true)
      allow(Rails.env).to receive(:production?).and_return(true)
    end

    it "generates the correct message and sends it to Teams" do
      described_class.perform_now
      expect(TeamsNotifierService).to have_received(:call)
    end

    context "when there are no missing providers" do
      before do
        allow(result).to receive_messages(
          training_partner_matches: [1, 2],
          provider_matches: [3],
          missing_accredited: [],
          missing_unaccredited: [],
          total_count: 3,
        )
      end

      it "sends a success message to Teams" do
        described_class.perform_now
        expect(TeamsNotifierService).to have_received(:call).with(
          {
            title: "Publish Provider Checker Results for #{Settings.current_recruitment_cycle_year} [test]",
            message: "Matching training partners: 2\n" \
                     "Matching providers: 1\n" \
                     "Missing accredited providers: 0\n" \
                     "Missing unaccredited providers: 0\n" \
                     "Total: 3\n",
            icon_emoji: "✅",
          },
        )
      end
    end

    context "when there is one missing provider" do
      before do
        allow(result).to receive_messages(
          training_partner_matches: [1, 2],
          provider_matches: [3],
          missing_accredited: [provider_record],
          missing_unaccredited: [unaccredited_provider_record],
          total_count: 5,
        )
      end

      it "sends a success message to Teams" do
        described_class.perform_now
        expect(TeamsNotifierService).to have_received(:call).with(
          {
            title: "Publish Provider Checker Results for #{Settings.current_recruitment_cycle_year} [test]",
            message: "Matching training partners: 2\n" \
                     "Matching providers: 1\n" \
                     "Missing accredited providers: 1\n" \
                     "  - University of BAT (A01), UKPRN 12345678\n\n" \
                     "Missing unaccredited providers: 1\n" \
                     "  - School of BAT (Z01), UKPRN 87654321\n\n" \
                     "Total: 5\n",
            icon_emoji: "🚨",
          },
        )
      end
    end
  end
end
