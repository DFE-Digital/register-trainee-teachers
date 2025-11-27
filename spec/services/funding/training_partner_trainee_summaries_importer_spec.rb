# frozen_string_literal: true

require "rails_helper"

module Funding
  describe TrainingPartnerTraineeSummariesImporter do
    describe described_class::SummaryRowMapper do
      describe "::TRAINING_ROUTES" do
        subject { described_class::TRAINING_ROUTES }

        it do
          expect(subject).to eq(
            "School Direct salaried" => "school_direct_salaried",
            "Post graduate teaching apprenticeship" => "pg_teaching_apprenticeship",
          )
        end
      end
    end

    context "valid attributes" do
      let(:summaries_attributes) do
        {
          "1111" => [
            {
              "Academic year" => "2021/22",
              "Provider" => "1111",
              "Provider name" => "Provider 1",
              "Subject" => "Physics",
              "Description" => "School Direct salaried",
              "Funding/trainee" => "24,000",
              "Trainees" => "2",
              "Total Funding" => "42,000",
            },
            {
              "Academic year" => "2021/22",
              "Provider" => "1111",
              "Provider name" => "Provider 1",
              "Subject" => "Modern Languages",
              "Description" => "School Direct salaried",
              "Funding/trainee" => "10000",
              "Trainees" => "0",
              "Total Funding" => "0",
            },
            {
              "Academic year" => "2021/22",
              "Provider" => "1111",
              "Provider name" => "Provider 1",
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
              "Provider" => "2222",
              "Provider name" => "Provider 2",
              "Subject" => "Physics",
              "Description" => " School Direct salaried ",
              "Funding/trainee" => "24000",
              "Trainees" => "0",
              "Total Funding" => "24000",
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
      let(:provider_one_third_row) { provider_one_summary.rows.last }
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
        let(:provider_one_expected_attributes) {
          {
            "route" => "School Direct salaried",
            "training_route" => "school_direct_salaried",
          }
        }

        let(:provider_two_expected_attributes) {
          {
            "subject" => "Physics",
            "route" => "School Direct salaried",
            "training_route" => "school_direct_salaried",
          }
        }

        it "creates the correct number of TraineeSummaryRows" do
          expect(provider_one_summary.rows.count).to eq(3)
          expect(provider_two_summary.rows.count).to eq(1)
        end

        it "creates TraineeSummaryRows with the correct attributes" do
          expect(provider_one_first_row.attributes).to include(
            provider_one_expected_attributes.merge({ "subject" => "Physics" }),
          )
          expect(provider_one_second_row.attributes).to include(
            provider_one_expected_attributes.merge({ "subject" => "Modern Languages" }),
          )
          expect(provider_one_third_row.attributes).to include(
            provider_one_expected_attributes.merge({ "subject" => "History" }),
          )
          expect(provider_two_first_row.attributes).to include(provider_two_expected_attributes)
        end
      end

      describe "TraineeSummaryRowAmount" do
        it "creates the correct number of TraineeSummaryRowAmounts" do
          expect(provider_one_first_row.amounts.count).to eq(1)
          expect(provider_one_second_row.amounts.count).to eq(0)
          expect(provider_one_third_row.amounts.count).to eq(0)
          expect(provider_two_first_row.amounts.count).to eq(0)
        end

        it "creates TraineeSummaryRowAmounts with the correct attributes" do
          expect(provider_one_first_row.amounts.first.attributes).to include(
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

    context "unknown provider" do
      let(:invalid_summaries_attributes) do
        {
          "4444" => [
            {
              "Academic year" => "2021/22",
              "Provider" => "4444",
              "Provider name" => "Provider 4",
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

      it "returns a list of missing provider accreditation_ids" do
        expect(subject).to eq(["4444"])
      end
    end
  end
end
