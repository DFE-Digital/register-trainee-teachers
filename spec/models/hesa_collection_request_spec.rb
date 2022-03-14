# frozen_string_literal: true

require "rails_helper"

describe HesaCollectionRequest do
  let(:settings_date) { Date.parse("2022-10-01") }
  let(:collection_reference) { "C123" }

  describe ".next_from_date" do
    before do
      allow(Settings.hesa).to receive(:current_collection_reference).and_return(collection_reference)
      allow(Settings.hesa).to receive(:current_collection_start_date).and_return(settings_date)
    end

    subject { described_class.next_from_date }

    context "where there is no previous request for the current collection" do
      it "returns the current collection start date" do
        expect(subject).to eq(settings_date)
      end
    end

    context "where there is a previous request for the current collection" do
      let(:requested_at) { 2.hours.ago }

      before do
        create(:hesa_collection_request,
               :import_successful,
               collection_reference: collection_reference,
               requested_at: requested_at)
      end

      it "returns the last request run date" do
        expect(subject).to eq(requested_at.to_date)
      end
    end
  end
end
