# frozen_string_literal: true

require "rails_helper"

module Hesa
  describe Backfilling do
    subject(:service) { described_class.call(trns: trainee.trn) }

    let(:trainee) { create(:trainee, :imported_from_hesa, :trn_received) }
    let(:xml_file_path) { Rails.root.join("spec/support/fixtures/hesa/itt_record.xml") }
    let(:url) do
      [
        Settings.hesa.collection_base_url,
        Settings.hesa.current_collection_reference,
        Settings.hesa.current_collection_start_date,
      ].join("/")
    end

    before do
      allow(Hesa::Client).to receive(:get).with(url: url).and_return(
        File.read(xml_file_path),
      )
    end

    describe "#call" do
      it "does not raise an error" do
        expect { service }.not_to raise_error
      end
    end
  end
end
