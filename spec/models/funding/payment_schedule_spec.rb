# frozen_string_literal: true

require "rails_helper"

module Funding
  describe PaymentSchedule do
    describe "associations" do
      it { is_expected.to have_many(:rows) }
      it { is_expected.to belong_to(:payable) }
    end

    describe "years" do
      let(:payment_schedule) { create(:payment_schedule, payable: build(:provider), rows: [row]) }
      let(:row) { build(:payment_schedule_row, amounts: [max_amount, min_amount]) }
      let(:min_amount) { build(:payment_schedule_row_amount, year: 2021) }
      let(:max_amount) { build(:payment_schedule_row_amount, year: 2022) }

      describe "start_year" do
        subject { payment_schedule.start_year }

        it "returns the minimum amount year" do
          expect(subject).to eq(2021)
        end
      end

      describe "end_year" do
        subject { payment_schedule.end_year }

        it "returns the maximum amount year" do
          expect(subject).to eq(2022)
        end
      end
    end

    describe "years with incomplete data" do
      context "rows are empty" do
        let(:payment_schedule_with_no_rows) { build(:payment_schedule) }

        describe "start_year" do
          subject { payment_schedule_with_no_rows.start_year }

          it "returns nil" do
            expect(subject).to be_nil
          end
        end

        describe "end_year" do
          subject { payment_schedule_with_no_rows.end_year }

          it "returns nil" do
            expect(subject).to be_nil
          end
        end
      end

      context "amounts are empty on the first row" do
        let(:payment_schedule_with_no_amounts) { build(:payment_schedule, rows: [build(:payment_schedule_row, amounts: [])]) }

        describe "start_year" do
          subject { payment_schedule_with_no_amounts.start_year }

          it "returns nil" do
            expect(subject).to be_nil
          end
        end

        describe "end_year" do
          subject { payment_schedule_with_no_amounts.end_year }

          it "returns nil" do
            expect(subject).to be_nil
          end
        end
      end
    end
  end
end
