# frozen_string_literal: true

require "rails_helper"

module Funding
  module Parsers
    describe LeadSchoolTraineeSummaries do
      context "valid csv" do
        let(:funding_upload) { create(:funding_upload, :lead_school_trainee_summaries) }
        let(:expected_lead_school_1111_result) do
          [
            {
              "Academic year" => "2021/22",
              "Lead school URN" => "1111",
              "Lead school name" => "Lead school 1",
              "Subject" => "Physics",
              "Description" => "School Direct salaried",
              "Funding/trainee" => "24000",
              "Trainees" => "0",
              "Total Funding" => "0",
            },
            {
              "Academic year" => "2021/22",
              "Lead school URN" => "1111",
              "Lead school name" => "Lead school 1",
              "Subject" => "Modern Languages",
              "Description" => "Post Graduate Teaching Apprenticeship",
              "Funding/trainee" => "10000",
              "Trainees" => "2",
              "Total Funding" => "20000",
            },
          ]
        end
        let(:expected_lead_school_2222_result) do
          [
            {
              "Academic year" => "2021/22",
              "Lead school URN" => "2222",
              "Lead school name" => "Lead school 2",
              "Subject" => "Mathematics",
              "Description" => "School Direct salaried",
              "Funding/trainee" => "24000",
              "Trainees" => "1",
              "Total Funding" => "24000",
            },
          ]
        end

        subject { described_class.to_attributes(funding_upload) }

        it "returns an hash with key for each provider" do
          expect(subject.keys).to match_array(%w[1111 2222])
        end

        it "returns a hash with an array of matching row hashes for each provider" do
          expect(subject["1111"]).to eq(expected_lead_school_1111_result)
          expect(subject["2222"]).to eq(expected_lead_school_2222_result)
        end
      end

      context "invalid csv" do
        let(:funding_upload) { create(:funding_upload, :invalid_lead_school_trainee_summaries) }

        subject { described_class.to_attributes(funding_upload) }

        it "is expected to raise error" do
          expect { subject }.to raise_error(NameError, "Column headings: Pubject, Tootal Funding not recognised")
        end
      end
    end
  end
end
