# frozen_string_literal: true

require "rails_helper"

module Funding
  describe AmountMatrix do
    describe ".for" do
      it "returns the three tier cells for the Early years tiered bursary" do
        cells = described_class.for(financial_incentive: "neither", funding_method: "early_years_tiered")

        expect(cells.map { |cell| [cell.key, cell.label, cell.funding_method] }).to eq([
          [:amount_tier_one, "Tier 1 amount", "7"],
          [:amount_tier_two, "Tier 2 amount", "8"],
          [:amount_tier_three, "Tier 3 amount", "9"],
        ])
      end

      it "returns the Financial Incentive split for other funding methods" do
        cells = described_class.for(financial_incentive: "degree_relevancy", funding_method: "D")

        expect(cells.map(&:key)).to eq(%i[amount_relevant amount_unrelated])
        expect(cells.map(&:funding_method)).to all(be_nil)
      end
    end

    describe "yearly routes (EYTDA)" do
      let(:eytda) { [TRAINING_ROUTE_ENUMS[:early_years_teacher_degree_apprenticeship]] }

      it "labels each training year with its short academic year" do
        expect(described_class.year_label(1, 2027)).to eq("Year 1 (27/28)")
        expect(described_class.year_label(4, 2027)).to eq("Year 4 (30/31)")
        expect(described_class.year_label(2, 2098)).to eq("Year 2 (99/00)")
      end

      it "returns one cell per training year for EYTDA, whatever the other answers" do
        cells = described_class.for(financial_incentive: "neither", funding_method: "E", training_routes: eytda, start_year: "2027")

        expect(cells.map { |cell| [cell.key, cell.label, cell.training_year] }).to eq([
          [:amount_year_1, "Year 1 (27/28)", 1],
          [:amount_year_2, "Year 2 (28/29)", 2],
          [:amount_year_3, "Year 3 (29/30)", 3],
        ])
      end

      it "names the year in errors" do
        cell = described_class.year_cells(2027).third

        expect(described_class.amount_error(cell, "")).to eq("Enter the Year 3 amount")
        expect(described_class.amount_error(cell, "6k")).to eq("Year 3 amount must be a whole number of pounds")
      end

      it "only treats EYTDA as yearly" do
        expect(described_class.yearly?(eytda)).to be(true)
        expect(described_class.yearly?([TRAINING_ROUTE_ENUMS[:teacher_degree_apprenticeship]])).to be(false)
      end
    end

    describe ".amount_error" do
      let(:tier_cell) { described_class.tier_cells.first }
      let(:plain_cell) { described_class.for_incentive("neither").first }

      it "names the tier for a tier cell" do
        expect(described_class.amount_error(tier_cell, "")).to eq("Enter the Tier 1 amount")
        expect(described_class.amount_error(tier_cell, "5k")).to eq("Tier 1 amount must be a whole number of pounds")
      end

      it "keeps the generic messages for other cells" do
        expect(described_class.amount_error(plain_cell, "")).to eq("Enter an amount")
        expect(described_class.amount_error(plain_cell, "1.5")).to eq("Amount must be a whole number of pounds")
      end

      it "accepts whole pounds" do
        expect(described_class.amount_error(tier_cell, "5000")).to be_nil
      end
    end
  end
end
