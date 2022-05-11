# frozen_string_literal: true

require "rails_helper"

module Funding
  describe ProviderTraineeSummariesImporter do
    context "valid attributes" do
      let(:summaries_attributes) do
        {
          "1111" => [
            {
              "Provider" => "1111",
              "Provider name" => "Provider 1",
              "Academic Year" => "2021/22",
              "Subject" => "Physics",
              "Route" => "Provider-led",
              "Lead School" => "Lead School 1",
              "Lead School ID" => "0001",
              "Cohort Level" => "PG",
              "Bursary Amount" => "24000",
              "Bursary Trainees" => "2",
              "Scholarship Amount" => "26000",
              "Scholarship Trainees" => "1",
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
              "Subject" => "Modern Languages",
              "Route" => "Provider-led",
              "Lead School" => "Lead School 1",
              "Lead School ID" => "0001",
              "Cohort Level" => "PG",
              "Bursary Amount" => "10000",
              "Bursary Trainees" => "0",
              "Scholarship Amount" => "0",
              "Scholarship Trainees" => "0",
              "Tier 1 Amount" => "0",
              "Tier 1 Trainees" => "0",
              "Tier 2 Amount" => "0",
              "Tier 2 Trainees" => "0",
              "Tier 3 Amount" => "0",
              "Tier 3 Trainees" => "0",
            },
          ],
          "2222" => [
            {
              "Provider" => "2222",
              "Provider name" => "Provider 2",
              "Academic Year" => "2021/22",
              "Subject" => "Modern Languages",
              "Route" => "Provider-led",
              "Lead School" => "Lead School 2",
              "Lead School ID" => "0002",
              "Cohort Level" => "PG",
              "Bursary Amount" => "0",
              "Bursary Trainees" => "0",
              "Scholarship Amount" => "0",
              "Scholarship Trainees" => "0",
              "Tier 1 Amount" => "15000",
              "Tier 1 Trainees" => "3",
              "Tier 2 Amount" => "10000",
              "Tier 2 Trainees" => "2",
              "Tier 3 Amount" => "5000",
              "Tier 3 Trainees" => "1",
            },
          ],
        }
      end

      let!(:provider_one) { create(:provider, accreditation_id: "1111") }
      let!(:provider_two) { create(:provider, accreditation_id: "2222") }

      let(:provider_one_summary) { provider_one.funding_trainee_summaries.last }
      let(:provider_two_summary) { provider_two.funding_trainee_summaries.last }

      let(:provider_one_first_row) { provider_one_summary.rows.first }
      let(:provider_one_second_row) { provider_one_summary.rows.second }
      let(:provider_two_first_row) { provider_two_summary.rows.first }

      subject { described_class.call(attributes: summaries_attributes) }

      before do
        subject
      end

      it "creates a TraineeSummary for each provider" do
        expect(provider_one.funding_trainee_summaries.count).to eq(1)
        expect(provider_two.funding_trainee_summaries.count).to eq(1)
      end

      it "creates a TraineeSummary for the academic year" do
        expect(provider_one_summary.academic_year).to eq("2021/22")
        expect(provider_two_summary.academic_year).to eq("2021/22")
      end

      describe "TraineeSummaryRow" do
        let(:provider_one_expected_attibutes) {
          {
            "route" => "Provider-led",
            "lead_school_name" => "Lead School 1",
            "lead_school_urn" => "0001",
            "cohort_level" => "PG",
          }
        }

        let(:provider_two_expected_attibutes) {
          {
            "subject" => "Modern Languages",
            "route" => "Provider-led",
            "lead_school_name" => "Lead School 2",
            "lead_school_urn" => "0002",
            "cohort_level" => "PG",
          }
        }

        it "creates the correct number of TraineeSummaryRows" do
          expect(provider_one_summary.rows.count).to eq(2)
          expect(provider_two_summary.rows.count).to eq(1)
        end

        it "creates TraineeSummaryRows with the correct attributes" do
          expect(provider_one_first_row.attributes).to include(
            provider_one_expected_attibutes.merge({ "subject" => "Physics" }),
          )
          expect(provider_one_second_row.attributes).to include(
            provider_one_expected_attibutes.merge({ "subject" => "Modern Languages" }),
          )
          expect(provider_two_first_row.attributes).to include(provider_two_expected_attibutes)
        end
      end

      describe "TraineeSummaryRowAmount" do
        it "creates the correct number of TraineeSummaryRowAmounts" do
          expect(provider_one_first_row.amounts.count).to eq(2)
          expect(provider_one_second_row.amounts.count).to eq(0)
          expect(provider_two_first_row.amounts.count).to eq(3)
        end

        it "creates TraineeSummaryRowAmounts with the correct attributes" do
          expect(provider_one_first_row.amounts.first.attributes).to include(
            {
              "amount" => 2_400_000,
              "number_of_trainees" => 2,
              "payment_type" => "bursary",
              "tier" => nil,
            },
          )

          expect(provider_one_first_row.amounts.second.attributes).to include(
            {
              "amount" => 2_600_000,
              "number_of_trainees" => 1,
              "payment_type" => "scholarship",
              "tier" => nil,
            },
          )

          expect(provider_two_first_row.amounts.first.attributes).to include(
            {
              "amount" => 1_500_000,
              "number_of_trainees" => 3,
              "payment_type" => "bursary",
              "tier" => 1,
            },
          )

          expect(provider_two_first_row.amounts.second.attributes).to include(
            {
              "amount" => 1_000_000,
              "number_of_trainees" => 2,
              "payment_type" => "bursary",
              "tier" => 2,
            },
          )

          expect(provider_two_first_row.amounts.last.attributes).to include(
            {
              "amount" => 500_000,
              "number_of_trainees" => 1,
              "payment_type" => "bursary",
              "tier" => 3,
            },
          )
        end
      end
    end

    context "unknown provider" do
      let(:invalid_summaries_attributes) do
        {
          "3333" => [
            {
              "Provider" => "3333",
              "Provider name" => "Provider 3",
              "Academic Year" => "2021/22",
              "Subject" => "Modern Languages",
              "Route" => "Provider-led",
              "Lead School" => "Lead School 3",
              "Lead School ID" => "0003",
              "Cohort Level" => "PG",
              "Bursary Amount" => "0",
              "Bursary Trainees" => "0",
              "Scholarship Amount" => "0",
              "Scholarship Trainees" => "0",
              "Tier 1 Amount" => "15000",
              "Tier 1 Trainees" => "3",
              "Tier 2 Amount" => "10000",
              "Tier 2 Trainees" => "2",
              "Tier 3 Amount" => "5000",
              "Tier 3 Trainees" => "1",
            },
          ],
        }
      end

      subject { described_class.call(attributes: invalid_summaries_attributes) }

      it "raises a PayableNotFoundError exception" do
        expect { subject }.to raise_error(PayableNotFoundError, "payable with id: 3333 doesn't exist")
      end
    end
  end
end
