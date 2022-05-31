# frozen_string_literal: true

require "rails_helper"

module Funding
  describe PaymentScheduleView do
    let(:payment_schedule) { create(:payment_schedule, :for_provider, rows: payment_schedule_rows) }

    subject { described_class.new(payment_schedule: payment_schedule) }

    describe "#actual_payments" do
      let(:payment_schedule_rows) do
        [
          build(:payment_schedule_row, amounts: [
            build(:payment_schedule_row_amount, month: 1, year: 2022, amount_in_pence: 100),
            build(:payment_schedule_row_amount, month: 2, year: 2022, amount_in_pence: 200),
            build(:payment_schedule_row_amount, month: 8, year: 2021, amount_in_pence: 50),
          ]),
        ]
      end

      it "returns actual payments ordered year, month" do
        expect(subject.actual_payments).to eq([
          {
            month: "August 2021",
            total: "£0.50",
            running_total: "£0.50",
          },
          {
            month: "January 2022",
            total: "£1.00",
            running_total: "£1.50",
          },
          {
            month: "February 2022",
            total: "£2.00",
            running_total: "£3.50",
          },
        ])
      end
    end

    describe "#predicted_payments" do
      let(:payment_schedule_rows) do
        [
          build(:payment_schedule_row, amounts: [
            build(:payment_schedule_row_amount, month: 1, year: 2022, amount_in_pence: 600, predicted: true),
            build(:payment_schedule_row_amount, month: 11, year: 2021, amount_in_pence: 100),
            build(:payment_schedule_row_amount, month: 12, year: 2021, amount_in_pence: 200, predicted: true),
          ]),
        ]
      end

      it "only returns predicted payments" do
        expect(subject.predicted_payments).to eq([
          {
            month: "December 2021",
            total: "£2.00",
            running_total: "£3.00",
          },
          {
            month: "January 2022",
            total: "£6.00",
            running_total: "£9.00",
          },
        ])
      end
    end

    describe "#payment_breakdown" do
      let(:payment_schedule_rows) do
        [
          build(:payment_schedule_row, description: "Payment Schedule 1", amounts: [
            build(:payment_schedule_row_amount, month: 1, year: 2022, amount_in_pence: 200),
            build(:payment_schedule_row_amount, month: 12, year: 2021, amount_in_pence: 500),

          ]),
          build(:payment_schedule_row, description: "Payment Schedule 2", amounts: [
            build(:payment_schedule_row_amount, month: 1, year: 2022, amount_in_pence: 300),
            build(:payment_schedule_row_amount, month: 12, year: 2021, amount_in_pence: 700),
          ]),
        ]
      end

      it "returns a list of monthly breakdown objects grouped by month and year" do
        expect(subject.payment_breakdown.map(&:to_h)).to eq([
          {
            title: "December 2021",
            rows: [
              { description: "Payment Schedule 1", amount: "£5.00", running_total: "£5.00" },
              { description: "Payment Schedule 2", amount: "£7.00", running_total: "£7.00" },
            ],
            total_amount: "£12.00",
            total_running_total: "£12.00",
          },
          {
            title: "January 2022",
            rows: [
              { description: "Payment Schedule 1", amount: "£2.00", running_total: "£7.00" },
              { description: "Payment Schedule 2", amount: "£3.00", running_total: "£10.00" },
            ],
            total_amount: "£5.00",
            total_running_total: "£17.00",
          },
        ])
      end
    end

    describe "#any?" do
      subject { described_class.new(payment_schedule: payment_schedule).any? }

      context "no payment schedule rows" do
        let(:payment_schedule_rows) { [] }

        it { is_expected.to be(false) }
      end

      context "payment schedule rows exist" do
        let(:payment_schedule_rows) do
          [
            build(:payment_schedule_row, amounts: [
              build(:payment_schedule_row_amount, month: 1, amount_in_pence: 100),
            ]),
          ]
        end

        it { is_expected.to be(true) }
      end
    end
  end
end
