# frozen_string_literal: true

require "rails_helper"

TRAINING_BURSARY_TRAINEES_HEADING = "Training bursary trainees"
COURSE_EXTENSION_PROVIDER_PAYMENTS_HEADING = "Course extension provider payments"
MONTH_TOTAL_HEADING = "Month total"
MONTH_HEADING = "Month"

module Exports
  describe FundingScheduleData do
    let!(:academic_cycle) { create(:academic_cycle, :current) }

    let(:payment_schedule) do
      create(:payment_schedule, :for_provider, :for_full_year)
    end

    subject(:exporter) { described_class.new(payment_schedule: payment_schedule) }

    describe "#data" do
      let(:expected_headers) do
        [
          MONTH_HEADING,
          TRAINING_BURSARY_TRAINEES_HEADING,
          COURSE_EXTENSION_PROVIDER_PAYMENTS_HEADING,
          MONTH_TOTAL_HEADING,
        ]
      end

      let(:expected_output) do
        course_total = 0
        training_total = 0
        grand_total = 0
        Funding::PayablePaymentSchedulesImporter::MONTH_ORDER.map do |month|
          training_amount = payment_schedule.rows.where(
            description: TRAINING_BURSARY_TRAINEES_HEADING,
          ).first.amounts.where(month: month).first.amount_in_pence
          course_amount = payment_schedule.rows.where(
            description: COURSE_EXTENSION_PROVIDER_PAYMENTS_HEADING,
          ).first.amounts.where(month: month).first.amount_in_pence
          year = month > 7 ? academic_cycle.start_year : academic_cycle.end_year
          course_total += course_amount
          training_total += training_amount
          grand_total += (course_amount + training_amount)

          {
            MONTH_HEADING => Date.new(year, month).to_s(:govuk_approx),
            TRAINING_BURSARY_TRAINEES_HEADING => training_amount,
            COURSE_EXTENSION_PROVIDER_PAYMENTS_HEADING => course_amount,
            MONTH_TOTAL_HEADING => training_amount + course_amount,
          }
        end + [
          {
            MONTH_HEADING => "Total",
            TRAINING_BURSARY_TRAINEES_HEADING => training_total,
            COURSE_EXTENSION_PROVIDER_PAYMENTS_HEADING => course_total,
            MONTH_TOTAL_HEADING => grand_total,
          },
        ]
      end

      it "sets the correct headers" do
        expect(exporter.data.first.keys).to match_array(expected_headers)
      end

      it "sets the correct row values" do
        expect(exporter.data).to eq(expected_output)
      end

      it "sets the correct filename" do
        expect(exporter.filename).to eq("#{payment_schedule.payable.name.downcase.gsub(' ', '-')}-payment_schedule-2021-to-2022.csv")
      end
    end

    describe "#to_csv" do
      let(:expected_header_line) do
        "Month,Training bursary trainees,Course extension provider payments,Month total"
      end

      let(:expected_data_line) do
        month = 8
        training_amount = payment_schedule.rows.where(
          description: TRAINING_BURSARY_TRAINEES_HEADING,
        ).first.amounts.where(month: month).first.amount_in_pence
        course_amount = payment_schedule.rows.where(
          description: COURSE_EXTENSION_PROVIDER_PAYMENTS_HEADING,
        ).first.amounts.where(month: month).first.amount_in_pence

        "August #{academic_cycle.start_year},#{format_amount(training_amount)},#{format_amount(course_amount)},#{format_amount(training_amount + course_amount)}"
      end

      it "Includes the header line" do
        expect(exporter.to_csv).to include(expected_header_line)
      end

      it "Formats data correctly" do
        expect(exporter.to_csv).to include(expected_data_line)
      end

      def format_amount(amount_in_pence)
        amount_in_pence.zero? ? "0" : "\"#{ActionController::Base.helpers.number_to_currency(amount_in_pence.to_d / 100, unit: '£')}\""
      end
    end
  end
end
