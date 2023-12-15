# frozen_string_literal: true

require "rails_helper"

describe HasAmountsInPence do
  let(:dummy_class) { Class.new { include HasAmountsInPence } }

  subject { dummy_class.new.in_pence(value) }

  describe "#in_pence" do
    context "valid value" do
      let(:value) { "£1,234.00" }

      it "returns value without comma and pound sign" do
        expect(subject).to eq(0.1234e6) # rubocop:disable Style/ExponentialNotation
      end
    end

    context "invalid value" do
      let(:value) { "$1" }

      it "returns zero values" do
        expect(subject).to eq(0.0)
      end
    end
  end
end
