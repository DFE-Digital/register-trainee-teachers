# frozen_string_literal: true

require "rails_helper"

module Hesa
  describe BackfillDegrees do
    subject(:service) { described_class.call(**params) }

    let(:params) { { trns: trainee.trn } }

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
      allow(::Hesa::Client).to receive(:get).with(url: url).and_return(
        ::File.read(xml_file_path),
      )
    end

    describe "#call" do
      context "without upload or local write" do
        it { expect { service }.not_to raise_error }
      end

      context "with upload" do
        let(:filename) { "itt_record.xml" }
        let(:upload) { create(:upload, name: filename, file: nil) }
        let(:params) { super().merge(upload_id: upload.id) }

        before do
          upload.file.attach(
            io: File.open(xml_file_path),
            filename: filename, content_type: "text/xml"
          )
        end

        it { expect { service }.not_to raise_error }
      end

      context "with local write" do
        let(:params) { super().merge(write_xml: true, path: "tmp/test") }

        it { expect { service }.not_to raise_error }
      end
    end
  end
end
