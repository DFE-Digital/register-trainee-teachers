# frozen_string_literal: true

require "rails_helper"

module Funding
  describe TraineeSummaryView do
    let(:maths_scholarship_amount) { 500000 }
    let(:maths_bursary_amount) { 200000 }
    let(:maths_grant_amount) { 300000 }
    let(:maths_scholarship_trainees) { 3 }
    let(:maths_bursary_trainees) { 2 }
    let(:maths_grant_trainees) { 3 }
    let(:biology_scholarship_amount) { 200000 }
    let(:biology_tiered_bursary_amount) { 100000 }
    let(:biology_scholarship_trainees) { 4 }
    let(:biology_tiered_bursary_trainees) { 5 }

    let(:total) {
      (maths_scholarship_amount * maths_scholarship_trainees) +
      (maths_bursary_amount * maths_bursary_trainees) +
      (maths_grant_amount * maths_grant_trainees) +
      (biology_scholarship_amount * biology_scholarship_trainees) +
      (biology_tiered_bursary_amount * biology_tiered_bursary_trainees)
    }

    let(:summary) do
      create(:trainee_summary, :for_provider).tap do |s|
        create(:trainee_summary_row, trainee_summary: s, subject: "Maths", route: "Provider-led", training_route: "provider_led_postgrad", lead_school_name: "BAT Academy").tap do |r|
          create(:trainee_summary_row_amount, row: r, payment_type: "scholarship", amount_in_pence: maths_scholarship_amount, number_of_trainees: maths_scholarship_trainees)
          create(:trainee_summary_row_amount, row: r, payment_type: "bursary", amount_in_pence: maths_bursary_amount, number_of_trainees: maths_bursary_trainees)
          create(:trainee_summary_row_amount, row: r, payment_type: "grant", amount_in_pence: maths_grant_amount, number_of_trainees: maths_grant_trainees)
        end
        create(:trainee_summary_row, trainee_summary: s, subject: "Biology", route: "Provider-led", training_route: "provider_led_postgrad", lead_school_name: "Regminster College").tap do |r|
          create(:trainee_summary_row_amount, row: r, payment_type: "bursary", tier: 1, amount_in_pence: biology_tiered_bursary_amount, number_of_trainees: biology_tiered_bursary_trainees)
          create(:trainee_summary_row_amount, row: r, payment_type: "scholarship", amount_in_pence: biology_scholarship_amount, number_of_trainees: biology_scholarship_trainees)
        end
      end
    end

    let(:route) { "Primary and secondary" }

    subject { TraineeSummaryView.new(trainee_summary: summary) }

    describe "#summary" do
      describe "#total" do
        it "returns the correct total from the summary" do
          expect(subject.summary.total).to eql(total)
        end
      end

      describe "#summary_data" do
        let(:expected_summary) do
          [
            TraineeSummaryView::PaymentTypeSummaryRow.new(payment_type: "ITT Bursaries", total: 400000),
            TraineeSummaryView::PaymentTypeSummaryRow.new(payment_type: "ITT Scholarship", total: 2300000),
            TraineeSummaryView::PaymentTypeSummaryRow.new(payment_type: "Early years ITT bursaries", total: 500000),
            TraineeSummaryView::PaymentTypeSummaryRow.new(payment_type: "Grants", total: 900000),
          ]
        end
        let(:summary_data_map) { subject.summary.summary_data.map { |d| [d.payment_type, d.total] } }
        let(:expected_summary_data) do
          [
            ["ITT bursaries", 400000],
            ["ITT scholarships", 2300000],
            ["Early years ITT bursaries", 500000],
            ["Grants", 900000],
          ]
        end

        it "returns the correct payment type and total" do
          expect(summary_data_map).to eql(expected_summary_data)
        end
      end
    end

    describe "#last_updated_at_string" do
      it "returns the created_at of the last trainee_summary in the correct format" do
        expect(subject.last_updated_at).to eq(summary.created_at.strftime("%d %B %Y"))
      end
    end

    describe "#bursary_breakdown_rows" do
      let(:bursary_array) {
        [
          {
            route: route,
            subject: "Maths",
            training_partner: "BAT Academy",
            trainees: maths_bursary_trainees,
            amount_per_trainee: "£2,000",
            total: "£4,000",
          },
        ]
      }

      context "when there are bursaries" do
        it "returns a breakdown of the bursaries" do
          expect(subject.bursary_breakdown_rows).to eq(bursary_array)
        end
      end
    end

    describe "#scholarship_breakdown_rows" do
      let(:scholarship_array) do
        [
          {
            route: route,
            subject: "Biology",
            training_partner: "Regminster College",
            trainees: biology_scholarship_trainees,
            amount_per_trainee: "£2,000",
            total: "£8,000",
          },
          {
            route: route,
            subject: "Maths",
            training_partner: "BAT Academy",
            trainees: maths_scholarship_trainees,
            amount_per_trainee: "£5,000",
            total: "£15,000",
          },
        ]
      end

      context "when there are scholarships" do
        it "returns a breakdown of the scholarships" do
          expect(subject.scholarship_breakdown_rows).to eq(scholarship_array)
        end
      end
    end

    describe "#tiered_bursary_breakdown_rows" do
      let(:tiered_bursary_array) do
        [
          {
            route: route,
            tier: "Tier 1",
            trainees: biology_tiered_bursary_trainees,
            amount_per_trainee: "£1,000",
            total: "£5,000",
          },
        ]
      end

      context "when there are tiered bursaries" do
        it "returns a breakdown of the tiered bursaries" do
          expect(subject.tiered_bursary_breakdown_rows).to eq(tiered_bursary_array)
        end
      end
    end

    describe "#grant_breakdown_rows" do
      let(:grant_array) do
        [
          {
            route: route,
            subject: "Maths",
            trainees: maths_grant_trainees,
            amount_per_trainee: "£3,000",
            total: "£9,000",
          },
        ]
      end

      context "when there are grants" do
        it "returns a breakdown of the grants" do
          expect(subject.grant_breakdown_rows).to eq(grant_array)
        end
      end
    end
  end
end
