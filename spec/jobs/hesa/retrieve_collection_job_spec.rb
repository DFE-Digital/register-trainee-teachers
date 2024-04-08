# frozen_string_literal: true

require "rails_helper"

module Hesa
  describe RetrieveCollectionJob do
    context "feature flag is off" do
      before { disable_features("hesa_import.sync_collection") }

      it "doesn't create a HesaCollectionRequest" do
        expect { described_class.new.perform }.not_to change { CollectionRequest.count }
      end

      it "doesn't call the HESA API" do
        expect(Hesa::Client).not_to receive(:get)
        described_class.new.perform
      end
    end

    context "feature flag is on" do
      let(:trainee) { create(:trainee) }
      let(:current_reference) { "C123" }
      let(:from_date) { "2022-04-01" }
      let(:expected_url) { "https://datacollection.hesa.ac.uk/apis/itt/1.1/CensusData/#{current_reference}/#{from_date}" }
      let(:hesa_api_stub) { ApiStubs::HesaApi.new }
      let(:hesa_xml) { ApiStubs::HesaApi.new.raw_xml }
      let(:last_hesa_collection_request) { CollectionRequest.last }

      before do
        enable_features("hesa_import.sync_collection")

        allow(Settings.hesa).to receive_messages(current_collection_start_date: from_date, current_collection_reference: current_reference)
        allow(Hesa::Client).to receive(:get).and_return(hesa_api_stub.raw_xml)
      end

      it "calls the HESA API" do
        expect(Hesa::Client).to receive(:get).with(url: expected_url)
        described_class.new.perform
      end

      it "calls the CreateFromHesaJob" do
        expect(CreateFromHesaJob).to receive(:perform_later).with(hesa_trainee: hesa_api_stub.student_attributes, record_source: RecordSources::HESA_COLLECTION)

        described_class.new.perform
      end

      describe "HesaCollectionRequest" do
        around do |example|
          Timecop.freeze do
            example.run
          end
        end

        before { described_class.new.perform }

        it "marks the import as successful" do
          expect(last_hesa_collection_request.state).to eq("import_successful")
        end

        it "creates a HesaCollectionRequest" do
          expect { described_class.new.perform }.to change { CollectionRequest.count }.by(1)
        end

        it "stores the xml" do
          expect(last_hesa_collection_request.response_body).to eq(hesa_xml)
        end

        it "stores the requested_at" do
          expected_time = Time.zone.now
          expect(last_hesa_collection_request.requested_at.tv_sec).to eq(expected_time.tv_sec)
        end
      end
    end
  end
end
