# frozen_string_literal: true

require "rails_helper"

module Funding
  describe LeadSchoolTraineeSummariesImporter do
    context "valid attributes" do
      let(:summaries_attributes) do
        {
          "1111" => [
            {
              "Academic year" => "2021/22",
              "Lead school URN" => "1111",
              "Lead school name" => "Lead School 1",
              "Subject" => "Physics",
              "Description" => "School Direct salaried",
              "Funding/trainee" => "24000",
              "Trainees" => "2",
              "Total Funding" => "42000",
            },
            {
              "Academic year" => "2021/22",
              "Lead school URN" => "1111",
              "Lead school name" => "Lead School 1",
              "Subject" => "Modern Languages",
              "Description" => "School Direct salaried",
              "Funding/trainee" => "10000",
              "Trainees" => "0",
              "Total Funding" => "0",
            },
            {
              "Academic year" => "2021/22",
              "Lead school URN" => "1111",
              "Lead school name" => "Lead School 1",
              "Subject" => "History",
              "Description" => "School Direct salaried",
              "Funding/trainee" => "0",
              "Trainees" => "1",
              "Total Funding" => "0",
            },
          ],
          "2222" => [
            {
              "Academic year" => "2021/22",
              "Lead school URN" => "2222",
              "Lead school name" => "Lead School 2",
              "Subject" => "Physics",
              "Description" => "School Direct salaried",
              "Funding/trainee" => "24000",
              "Trainees" => "0",
              "Total Funding" => "24000",
            },
          ],
        }
      end

      let!(:lead_school_one) { create(:school, :lead, urn: "1111") }
      let!(:lead_school_two) { create(:school, :lead, urn: "2222") }

      let(:lead_school_one_summary) { lead_school_one.funding_trainee_summaries.last }
      let(:lead_school_two_summary) { lead_school_two.funding_trainee_summaries.last }

      let(:lead_school_one_first_row) { lead_school_one_summary.rows.first }
      let(:lead_school_one_second_row) { lead_school_one_summary.rows.second }
      let(:lead_school_one_third_row) { lead_school_one_summary.rows.last }
      let(:lead_school_two_first_row) { lead_school_two_summary.rows.first }

      subject { described_class.call(attributes: summaries_attributes) }

      before do
        subject
      end

      it "creates a TraineeSummary for each lead school" do
        expect(lead_school_one.funding_trainee_summaries.count).to eq(1)
        expect(lead_school_two.funding_trainee_summaries.count).to eq(1)
      end

      it "creates a TraineeSummary for the academic year" do
        expect(lead_school_one_summary.academic_year).to eq("2021/22")
        expect(lead_school_two_summary.academic_year).to eq("2021/22")
      end

      describe "TraineeSummaryRow" do
        let(:lead_school_one_expected_attibutes) {
          {
            "route" => "School Direct salaried",
            "lead_school_name" => "Lead School 1",
            "lead_school_urn" => "1111",
          }
        }

        let(:lead_school_two_expected_attibutes) {
          {
            "subject" => "Physics",
            "route" => "School Direct salaried",
            "lead_school_name" => "Lead School 2",
            "lead_school_urn" => "2222",
          }
        }

        it "creates the correct number of TraineeSummaryRows" do
          expect(lead_school_one_summary.rows.count).to eq(3)
          expect(lead_school_two_summary.rows.count).to eq(1)
        end

        it "creates TraineeSummaryRows with the correct attributes" do
          expect(lead_school_one_first_row.attributes).to include(
            lead_school_one_expected_attibutes.merge({ "subject" => "Physics" }),
          )
          expect(lead_school_one_second_row.attributes).to include(
            lead_school_one_expected_attibutes.merge({ "subject" => "Modern Languages" }),
          )
          expect(lead_school_one_third_row.attributes).to include(
            lead_school_one_expected_attibutes.merge({ "subject" => "History" }),
          )
          expect(lead_school_two_first_row.attributes).to include(lead_school_two_expected_attibutes)
        end
      end

      describe "TraineeSummaryRowAmount" do
        it "creates the correct number of TraineeSummaryRowAmounts" do
          expect(lead_school_one_first_row.amounts.count).to eq(1)
          expect(lead_school_one_second_row.amounts.count).to eq(0)
          expect(lead_school_one_third_row.amounts.count).to eq(0)
          expect(lead_school_two_first_row.amounts.count).to eq(0)
        end

        it "creates TraineeSummaryRowAmounts with the correct attributes" do
          expect(lead_school_one_first_row.amounts.first.attributes).to include(
            {
              "amount_in_pence" => 2_400_000,
              "number_of_trainees" => 2,
              "payment_type" => "grant",
              "tier" => nil,
            },
          )
        end
      end
    end

    context "unknown school" do
      let(:invalid_summaries_attributes) do
        {
          "4444" => [
            {
              "Academic year" => "2021/22",
              "Lead school URN" => "4444",
              "Lead school name" => "Lead School 4",
              "Subject" => "Physics",
              "Description" => "School Direct salaried",
              "Funding/trainee" => "24000",
              "Trainees" => "0",
              "Total Funding" => "24000",
            },
          ],
        }
      end

      subject { described_class.call(attributes: invalid_summaries_attributes) }

      it "returns a list of missing lead school urns" do
        expect(subject).to eq(["4444"])
      end
    end
  end
end
