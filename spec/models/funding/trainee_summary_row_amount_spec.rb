# frozen_string_literal: true

require "rails_helper"

module Funding
  describe TraineeSummaryRowAmount do
    let(:summary) { create(:trainee_summary, :for_provider) }
    let(:summary_row) { create(:trainee_summary_row, trainee_summary: summary) }

    describe "associations" do
      it { is_expected.to belong_to(:row) }
    end

    describe "untiered_bursary?" do
      let(:summary_row_amount) { create(:trainee_summary_row_amount, :with_bursary, row: summary_row) }

      subject { summary_row_amount.untiered_bursary? }

      context "a bursary payment type exists" do
        it "returns true" do
          expect(subject).to be true
        end
      end
    end

    describe "tiered_bursary?" do
      let(:summary_row_amount) { create(:trainee_summary_row_amount, :with_tiered_bursary, row: summary_row) }

      subject { summary_row_amount.tiered_bursary? }

      context "a tiered bursary payment type exists" do
        it "returns true" do
          expect(subject).to be true
        end
      end
    end
  end
end
