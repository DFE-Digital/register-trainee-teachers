# frozen_string_literal: true

require "rails_helper"

describe Exports::BulkRecommendEmptyExport, type: :model do
  describe "#call" do
    subject(:service) { described_class.call }

    let(:csv) { CSV.parse(service, headers: true) }

    let(:expected_headers) do
      [
        "TRN",
        "Provider trainee ID",
        "Date QTS or EYTS requirement met",
      ]
    end

    context "when generated" do
      it "only includes a heading row" do
        expect(csv.size).to be_zero
      end

      it "includes the correct header labels" do
        expect(csv.headers).to match_array(expected_headers)
      end
    end
  end
end
