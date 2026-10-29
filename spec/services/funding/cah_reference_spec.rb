# frozen_string_literal: true

require "rails_helper"

module Funding
  describe CahReference do
    describe ".level_2_options" do
      it "returns the level 2 children of the given level 1 — not another category's" do
        options = described_class.level_2_options("CAH09") # mathematical sciences
        expect(options.map(&:first)).to all(start_with("CAH09-"))
        expect(options.map(&:last).join).to match(/Mathematical/i)
        expect(options.map(&:last).join).not_to match(/Medicine/i)
      end

      it "returns nothing for a blank or unknown level 1" do
        expect(described_class.level_2_options("")).to eq([])
        expect(described_class.level_2_options("NOPE")).to eq([])
      end
    end

    describe ".level_2_name" do
      it "names the correct category (regression: CAH09 is not Medicine)" do
        expect(described_class.level_2_name("CAH09-01")).to match(/Mathematical/i)
        expect(described_class.level_2_name("CAH01-01")).to match(/Medicine/i)
      end
    end

    describe ".hecos_options / .hecos_codes_for" do
      it "returns the HECoS codes under the given level 2" do
        codes = described_class.hecos_codes_for("CAH09-01")
        expect(codes).to be_present
        # a maths HECoS code sits under CAH09-01; a medicine one does not
        medicine_codes = described_class.hecos_codes_for("CAH01-01")
        expect(codes & medicine_codes).to be_empty
      end
    end
  end
end
