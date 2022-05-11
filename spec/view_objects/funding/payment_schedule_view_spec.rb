# frozen_string_literal: true

require "rails_helper"

module Funding
  describe PaymentScheduleView do
    let(:payment_schedule) { build(:payment_schedule, :for_provider, rows: payment_schedule_rows) }

    subject { described_class.new(payment_schedule: payment_schedule) }

    describe "#actual_payments" do
      let(:payment_schedule_rows) do
        [
          build(:payment_schedule_row, amounts: [
            build(:payment_schedule_row_amount, month: 1, amount_in_pence: 100),
            build(:payment_schedule_row_amount, month: 2, amount_in_pence: 200),
          ]),
        ]
      end

      it "returns actual payments" do
        expect(subject.actual_payments).to eq([
          {
            month: "January 2022",
            total: "£1.00",
            running_total: "£1.00",
          },
          {
            month: "February 2022",
            total: "£2.00",
            running_total: "£3.00",
          },
        ])
      end
    end

    describe "#predicted_payments" do
      let(:payment_schedule_rows) do
        [
          build(:payment_schedule_row, amounts: [
            build(:payment_schedule_row_amount, month: 1, amount_in_pence: 100),
            build(:payment_schedule_row_amount, month: 2, amount_in_pence: 200, predicted: true),
            build(:payment_schedule_row_amount, month: 3, amount_in_pence: 600, predicted: true),
          ]),
        ]
      end

      it "only returns predicted payments" do
        expect(subject.predicted_payments).to eq([
          {
            month: "February 2022",
            total: "£2.00",
            running_total: "£2.00",
          },
          {
            month: "March 2022",
            total: "£6.00",
            running_total: "£8.00",
          },
        ])
      end
    end

    describe "#payment_breakdown" do
      let(:current_year) { Time.zone.now.year }
      let(:payment_schedule_rows) do
        [
          build(:payment_schedule_row, description: "Payment Schedule 1", amounts: [
            build(:payment_schedule_row_amount, month: 1, amount_in_pence: 200),
            build(:payment_schedule_row_amount, month: 2, amount_in_pence: 500),

          ]),
          build(:payment_schedule_row, description: "Payment Schedule 2", amounts: [
            build(:payment_schedule_row_amount, month: 1, amount_in_pence: 300),
            build(:payment_schedule_row_amount, month: 2, amount_in_pence: 700),
          ]),
        ]
      end

      it "returns a list of monthly breakdown objects grouped by month and year" do
        expect(subject.payment_breakdown.map(&:to_h)).to eq([
          {
            title: "January #{current_year}",
            rows: [
              { description: "Payment Schedule 1", amount: "£2.00", running_total: "£2.00" },
              { description: "Payment Schedule 2", amount: "£3.00", running_total: "£3.00" },
            ],
            total_amount: "£5.00",
            total_running_total: "£5.00",
          },
          {
            title: "February #{current_year}",
            rows: [
              { description: "Payment Schedule 1", amount: "£5.00", running_total: "£7.00" },
              { description: "Payment Schedule 2", amount: "£7.00", running_total: "£10.00" },
            ],
            total_amount: "£12.00",
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
