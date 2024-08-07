# frozen_string_literal: true

require "rails_helper"

module Hesa
  describe RetrieveTrnDataJob do
    context "feature flag is off" do
      before { disable_features("hesa_import.sync_trn_data") }

      it "doesn't create a HesaTrnRequest" do
        expect { described_class.new.perform }.not_to change { TrnRequest.count }
      end

      it "doesn't call the HESA API" do
        expect(Hesa::Client).not_to receive(:get)
        described_class.new.perform
      end
    end

    context "feature flag is on" do
      let(:trainee) { build(:trainee) }
      let(:current_reference) { "C123" }
      let(:from_date) { "2022-04-01" }
      let(:expected_url) { "https://datacollection.hesa.ac.uk/apis/itt/1.1/TRNData/#{current_reference}/Latest" }
      let(:hesa_api_stub) { ApiStubs::HesaApi.new }
      let(:hesa_xml) { ApiStubs::HesaApi.new.raw_xml }
      let(:ukprn) { hesa_api_stub.student_attributes[:ukprn] }
      let(:last_hesa_trn_request) { TrnRequest.last }

      before do
        enable_features("hesa_import.sync_trn_data")

        allow(Settings.hesa).to receive(:current_collection_reference).and_return(current_reference)
        allow(Hesa::Client).to receive(:get).and_return(hesa_api_stub.raw_xml)
        allow(Trainees::CreateFromHesa).to receive(:call).and_return([trainee, ukprn])
      end

      it "calls the HESA API" do
        expect(Hesa::Client).to receive(:get).with(url: expected_url)
        described_class.new.perform
      end

      it "calls the CreateFromHesaJob" do
        expect(CreateFromHesaJob).to receive(:perform_later).with(hesa_trainee: hesa_api_stub.student_attributes, record_source: Trainee::HESA_TRN_DATA_SOURCE)

        described_class.new.perform
      end

      describe "HesaTrnRequest" do
        around do |example|
          Timecop.freeze do
            example.run
          end
        end

        before { described_class.new.perform }

        it "marks the import as successful" do
          expect(last_hesa_trn_request.state).to eq("import_successful")
        end

        it "creates a HesaTrnRequest" do
          expect { described_class.new.perform }.to change { TrnRequest.count }.by(1)
        end

        it "stores the xml" do
          expect(last_hesa_trn_request.response_body).to eq(hesa_xml)
        end
      end
    end
  end
end
