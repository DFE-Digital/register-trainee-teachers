# frozen_string_literal: true

require "rails_helper"

describe HesaCollectionRequest do
  describe ".next_from_date" do
    before do
      allow(Settings.hesa).to receive(:current_collection_reference).and_return("C123")
      allow(Settings.hesa).to receive(:current_collection_start_date).and_return("2022-10-01")
    end

    subject { described_class.next_from_date }

    context "where there is no previous request for the current collection" do
      it "returns the current collection start date" do
        expect(subject).to eq(DateTime.parse("2022-10-01").utc.iso8601)
      end
    end

    context "where there is a previous request for the current collection" do
      let!(:previous_request) { create(:hesa_collection_request, collection_reference: "C123", requested_at: "10/01/2022 13:00:00") }

      it "returns the last request run datetime" do
        expect(subject).to eq(previous_request.requested_at.utc.iso8601)
      end
    end
  end
end
