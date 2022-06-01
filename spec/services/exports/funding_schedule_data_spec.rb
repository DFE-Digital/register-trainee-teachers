# frozen_string_literal: true

require "rails_helper"

module Exports
  describe FundingScheduleData do
    before do
      @academic_cycle = create(:academic_cycle, :current) 
    end

    let(:payment_schedule) do
      create(:payment_schedule, :for_provider, :for_full_year)
    end

    subject(:exporter) { described_class.new(payment_schedule: payment_schedule) }

    describe "#data" do
      let(:expected_headers) do
        [
          "Month",
          "Training bursary trainees",
          "Course extension provider payments",
          "Month total",
        ]
      end

      let(:expected_output) do
        course_total = 0
        training_total = 0
        grand_total = 0
        Funding::PayablePaymentSchedulesImporter::MONTH_ORDER.map do |month|
          training_amount = payment_schedule.rows.where(
            description: "Training bursary trainees"
          ).first.amounts.where(month: month).first.amount_in_pence
          course_amount = payment_schedule.rows.where(
            description: "Course extension provider payments"
          ).first.amounts.where(month: month).first.amount_in_pence
          year = month > 7 ? @academic_cycle.start_year : @academic_cycle.end_year
          course_total += course_amount
          training_total += training_amount
          grand_total += (course_amount + training_amount)

          {
            "Month" => Date.new(year, month).to_s(:govuk_approx),
            "Training bursary trainees" => training_amount,
            "Course extension provider payments" => course_amount,
            "Month total" => training_amount + course_amount,
          }
        end + [
          {
            "Month" => "Total",
            "Training bursary trainees" => training_total,
            "Course extension provider payments" => course_total,
            "Month total" => grand_total,
          }
        ]
      end

      it "sets the correct headers" do
        expect(exporter.data.first.keys).to match_array(expected_headers)
      end

      it "sets the correct row values" do
        expect(exporter.data).to eq(expected_output)
      end
    end
  end
end
