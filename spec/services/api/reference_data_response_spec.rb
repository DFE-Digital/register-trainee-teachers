# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::ReferenceDataResponse do
  describe ".call" do
    context "with a supported version" do
      subject(:response) { described_class.call(version: "v2026.1") }

      it "returns the reference data payload" do
        expect(response.fetch(:status)).to eq(:ok)
        expect(response.fetch(:json).keys).to include(:sex, :withdrawal_reasons)
      end
    end

    context "with an unsupported version" do
      it "raises UnsupportedVersionError" do
        expect { described_class.call(version: "v2025.0") }
          .to raise_error(described_class::UnsupportedVersionError)
      end
    end
  end
end
