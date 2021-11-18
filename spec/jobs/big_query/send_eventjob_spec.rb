# frozen_string_literal: true

require "rails_helper"

module BigQuery
  describe SendEventJob do
    let(:dataset_name) { "dataset" }
    let(:table_name) { "table" }
    let(:bigquery) { double }
    let(:dataset) { double }
    let(:table) { double }
    let(:event_json) { { "event" => "json" } }

    before do
      allow(Google::Cloud::Bigquery).to receive(:new).and_return(bigquery)
      allow(bigquery).to receive(:dataset).with(dataset_name, skip_lookup: true).and_return(dataset)
      allow(dataset).to receive(:table).with(table_name, skip_lookup: true).and_return(table)
    end

    context "feature enabled" do
      before do
        enable_features("google.send_data_to_big_query")
      end

      it "inserts the json into the table" do
        expect(table).to receive(:insert).with([event_json])
        described_class.new.perform(event_json: event_json, dataset: dataset_name, table: table_name)
      end
    end

    context "feature disabled" do
      before do
        disable_features("google.send_data_to_big_query")
      end

      it "noops" do
        expect(Google::Cloud::Bigquery).not_to receive(:new)
        expect(described_class.new.perform(event_json: event_json, dataset: dataset_name, table: table_name)).to be_nil
      end
    end
  end
end
