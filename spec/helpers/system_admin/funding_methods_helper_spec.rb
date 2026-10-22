# frozen_string_literal: true

require "rails_helper"

module SystemAdmin
  describe FundingMethodsHelper, type: :helper do
    describe "#funding_method_options" do
      it "offers one Early years tiered bursary option instead of Tier 1, 2 and 3" do
        expect(helper.funding_method_options("bursary")).to eq([
          ["D", "Postgraduate bursary"],
          ["B", "Undergraduate bursary"],
          ["C", "Veteran Teaching undergraduate bursary"],
          ["early_years_tiered", "Early years tiered bursary"],
        ])
      end
    end

    describe "#funding_method_label" do
      it "labels each tier as part of the Early years tiered bursary" do
        expect(helper.funding_method_label("9")).to eq("Early years tiered bursary: Tier 3")
        expect(helper.funding_method_label("early_years_tiered")).to eq("Early years tiered bursary")
      end
    end

    describe "#funding_method_cell" do
      it "uses the stored HESA burslev when present" do
        # "7" = Tier 1 — cannot be derived from a band, only stored
        expect(helper.funding_method_cell("7", "bursary", TRAINING_ROUTE_ENUMS[:early_years_postgrad])).to eq("Early years tiered bursary: Tier 1")
      end

      it "derives Postgraduate bursary for a bursary on a postgraduate route" do
        expect(helper.funding_method_cell(nil, "bursary", TRAINING_ROUTE_ENUMS[:provider_led_postgrad])).to eq("Postgraduate bursary")
      end

      it "derives Undergraduate bursary for a bursary on an undergraduate route" do
        expect(helper.funding_method_cell(nil, "bursary", TRAINING_ROUTE_ENUMS[:provider_led_undergrad])).to eq("Undergraduate bursary")
      end

      it "derives Scholarship and Grant from the funding type" do
        expect(helper.funding_method_cell(nil, "scholarship", TRAINING_ROUTE_ENUMS[:provider_led_postgrad])).to eq("Scholarship")
        expect(helper.funding_method_cell(nil, "grant", TRAINING_ROUTE_ENUMS[:school_direct_salaried])).to eq("Grant")
      end
    end
  end
end
