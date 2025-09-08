# frozen_string_literal: true

require "rails_helper"

module Funding
  module Parsers
    describe ProviderTraineeSummaries do
      context "valid csv" do
        let(:funding_upload) { create(:funding_upload, :provider_trainee_summaries) }
        let(:expected_provider_1111_result) do
          [
            {
              "Provider" => "1111",
              "Provider name" => "Provider 1",
              "Academic Year" => "2021/22",
              "Subject" => "Physics",
              "Route" => "Provider-led",
              "Lead School" => nil,
              "Lead School ID" => nil,
              "Cohort Level" => "PG",
              "Bursary Amount" => "24000",
              "Bursary Trainees" => "2",
              "Scholarship Amount" => "0",
              "Scholarship Trainees" => "0",
              "Tier 1 Amount" => "0",
              "Tier 1 Trainees" => "0",
              "Tier 2 Amount" => "0",
              "Tier 2 Trainees" => "0",
              "Tier 3 Amount" => "0",
              "Tier 3 Trainees" => "0",
            },
            {
              "Provider" => "1111",
              "Provider name" => "Provider 1",
              "Academic Year" => "2021/22",
              "Subject" => "Business studies",
              "Route" => "Teacher degree apprenticeship",
              "Lead School" => nil,
              "Lead School ID" => nil,
              "Cohort Level" => "PG",
              "Bursary Amount" => "0",
              "Bursary Trainees" => "0",
              "Scholarship Amount" => "18000",
              "Scholarship Trainees" => "5",
              "Tier 1 Amount" => "0",
              "Tier 1 Trainees" => "0",
              "Tier 2 Amount" => "0",
              "Tier 2 Trainees" => "0",
              "Tier 3 Amount" => "0",
              "Tier 3 Trainees" => "0",
            },
          ]
        end
        let(:expected_provider_2222_result) do
          [
            {
              "Provider" => "2222",
              "Provider name" => "Provider 2",
              "Academic Year" => "2021/22",
              "Subject" => "Computing",
              "Route" => "School Direct tuition fee",
              "Lead School" => "Lead school 2",
              "Lead School ID" => "0002",
              "Cohort Level" => "PG",
              "Bursary Amount" => "0",
              "Bursary Trainees" => "0",
              "Scholarship Amount" => "0",
              "Scholarship Trainees" => "0",
              "Tier 1 Amount" => "3000",
              "Tier 1 Trainees" => "3",
              "Tier 2 Amount" => "2000",
              "Tier 2 Trainees" => "2",
              "Tier 3 Amount" => "1000",
              "Tier 3 Trainees" => "1",
            },
          ]
        end

        subject { described_class.to_attributes(funding_upload:) }

        it "returns an hash with key for each provider" do
          expect(subject.keys).to match_array(%w[1111 2222])
        end

        it "returns a hash with an array of matching row hashes for each provider" do
          expect(subject["1111"]).to eq(expected_provider_1111_result)
          expect(subject["2222"]).to eq(expected_provider_2222_result)
        end
      end

      context "invalid csv" do
        let(:funding_upload) { create(:funding_upload, :invalid_provider_trainee_summaries) }

        subject { described_class.to_attributes(funding_upload:) }

        it "is expected to raise error" do
          expect { subject }.to raise_error(NameError, "Column headings: Provider thingy not recognised")
        end
      end
    end
  end
end
