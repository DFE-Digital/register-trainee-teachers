# frozen_string_literal: true

require "rails_helper"

module Hesa
  describe RetrieveCollectionJob do
    context "feature flag is off" do
      before { disable_features :sync_from_hesa }

      it "doesn't create a HesaCollectionRequest" do
        expect { described_class.new.perform }.not_to change { HesaCollectionRequest.count }
      end

      it "doesn't call the HESA API" do
        expect(Hesa::Client).not_to receive(:get)
        described_class.new.perform
      end
    end

    context "feature flag is on" do
      let(:current_reference) { "C123" }
      let(:next_date) { DateTime.parse("10/01/2022").utc.iso8601 }
      let(:expected_url) { "https://datacollection.hesa.ac.uk/apis/itt/1.1/CensusData/#{current_reference}/#{next_date}" }
      let(:shouty_xml) { "<SHOUTYXML></SHOUTYXML>" }

      before do
        enable_features :sync_from_hesa
        allow(Settings.hesa).to receive(:current_collection_reference).and_return("C123")
        allow(HesaCollectionRequest).to receive(:next_from_date).and_return(next_date)
        allow(Hesa::Client).to receive(:get).and_return(shouty_xml)
      end

      it "creates a HesaCollectionRequest" do
        expect { described_class.new.perform }.to change { HesaCollectionRequest.count }.by(1)
      end

      it "calls the HESA API" do
        expect(Hesa::Client).to receive(:get).with(url: expected_url)
        described_class.new.perform
      end

      def created_hesa_collection_request
        described_class.new.perform
        HesaCollectionRequest.last
      end

      it "stores the xml" do
        expect(created_hesa_collection_request.response_body).to eq(shouty_xml)
      end

      it "stores the requested_at" do
        Timecop.freeze do
          expected_time = Time.zone.now
          expect(created_hesa_collection_request.requested_at.tv_sec).to eq(expected_time.tv_sec)
        end
      end

      it "stores updates_since" do
        expect(created_hesa_collection_request.updates_since).to eq(next_date)
      end
    end
  end
end
