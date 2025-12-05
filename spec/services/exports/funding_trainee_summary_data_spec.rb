# frozen_string_literal: true

require "rails_helper"

module Exports
  describe FundingTraineeSummaryData do
    let!(:payable) { create(:school, name: "Fussington Academy") }
    let!(:trainee_summary) { create(:trainee_summary, :for_school) }
    let!(:trainee_summary_row) { create(:trainee_summary_row, trainee_summary: trainee_summary, lead_school_urn: payable.urn) }
    let!(:tiered_bursary_amount) { create(:trainee_summary_row_amount, :with_tiered_bursary, row: trainee_summary_row) }
    let!(:empty_trainee_summary_row) { create(:trainee_summary_row, trainee_summary:) }

    subject { described_class.new(trainee_summary, payable.name) }

    describe "#csv" do
      let(:expected_output) do
        {
          "Funding type" => "ITT #{tiered_bursary_amount.payment_type}",
          "Route" => trainee_summary_row.route,
          "Course" => trainee_summary_row.subject,
          "Lead school" => trainee_summary_row.lead_school_name,
          "Tier" => "Tier #{tiered_bursary_amount.tier}",
          "Number of trainees" => tiered_bursary_amount.number_of_trainees,
          "Amount per trainee" => "\"#{ActionController::Base.helpers.number_to_currency(tiered_bursary_amount.amount_in_pence.to_d / 100, unit: '£')}\"",
          "Total" => "\"#{ActionController::Base.helpers.number_to_currency(tiered_bursary_amount.number_of_trainees * tiered_bursary_amount.amount_in_pence.to_d / 100, unit: '£')}\"",
        }
      end

      let(:csv_title) { "fussington-academy-trainee-summary-#{current_academic_year}-to-#{current_academic_year + 1}.csv" }

      it "sets the correct headers" do
        expect(subject.csv).to include(expected_output.keys.join(","))
      end

      it "sets the correct row values" do
        expect(subject.csv).to include(expected_output.values.join(","))
      end

      it "skips rows without amounts" do
        expected_csv_with_headers_row_count = 2
        expect(CSV.parse(subject.csv).length).to eq(expected_csv_with_headers_row_count)
      end

      it "sets the correct title" do
        expect(subject.filename).to include(csv_title)
      end

      context "when there are no trainee summaries" do
        let!(:scholarship_amount) { create(:trainee_summary_row_amount, :with_scholarship, row: trainee_summary_row) }
        let(:bursary_expected_output) do
          {
            "Funding type" => "ITT #{tiered_bursary_amount.payment_type}",
            "Route" => trainee_summary_row.route,
            "Course" => trainee_summary_row.subject,
            "Lead school" => trainee_summary_row.lead_school_name,
            "Tier" => "Tier #{tiered_bursary_amount.tier}",
            "Number of trainees" => tiered_bursary_amount.number_of_trainees,
            "Amount per trainee" => "\"#{ActionController::Base.helpers.number_to_currency(tiered_bursary_amount.amount_in_pence.to_d / 100, unit: '£')}\"",
            "Total" => "\"#{ActionController::Base.helpers.number_to_currency(tiered_bursary_amount.number_of_trainees * tiered_bursary_amount.amount_in_pence.to_d / 100, unit: '£')}\"",
          }
        end
        let(:scholarship_expected_output) do
          {
            "Funding type" => "ITT #{scholarship_amount.payment_type}",
            "Route" => trainee_summary_row.route,
            "Course" => trainee_summary_row.subject,
            "Lead school" => trainee_summary_row.lead_school_name,
            "Tier" => "Not applicable",
            "Number of trainees" => scholarship_amount.number_of_trainees,
            "Amount per trainee" => "\"#{ActionController::Base.helpers.number_to_currency(scholarship_amount.amount_in_pence.to_d / 100, unit: '£')}\"",
            "Total" => "\"#{ActionController::Base.helpers.number_to_currency(scholarship_amount.number_of_trainees * scholarship_amount.amount_in_pence.to_d / 100, unit: '£')}\"",
          }
        end

        it "sets the correct row values" do
          expect(subject.csv).to include(bursary_expected_output.values.join(","))
          expect(subject.csv).to include(scholarship_expected_output.values.join(","))
        end
      end
    end
  end
end
