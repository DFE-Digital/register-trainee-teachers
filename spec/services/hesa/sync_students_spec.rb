# frozen_string_literal: true

require "rails_helper"

module Hesa
  describe SyncStudents do
    subject(:service) { described_class.call }
    let(:xml_file_path) { Rails.root.join("spec/support/fixtures/hesa/itt_record.xml") }
    let(:xml_response) { File.read(xml_file_path) }
    let(:url) do
      [
        Settings.hesa.collection_base_url,
        Settings.hesa.current_collection_reference,
        Settings.hesa.current_collection_start_date,
      ].join("/")
    end

    before do
      allow(::Hesa::Client).to receive(:get).with(url:).and_return(xml_response)
    end

    describe ".call" do
      it "fetches the collection XML and creates a Hesa::Student record" do
        expect { described_class.call }.to change { Student.count }.from(0).to(1)
      end

      context "XML is empty" do
        let(:xml_response) { "" }

        it "doesn't try to parse the XML response" do
          expect { described_class.call }.not_to raise_error(Nokogiri::XML::SyntaxError)
        end
      end

      context "hesa record spanning two collections" do
        let!(:hesa_student) { create(:hesa_student, hesa_id: "0310261553101", rec_id: "16054") }

        it "creates new collection record" do
          expect { described_class.call }.to change { Student.count }.from(1).to(2)
        end
      end
    end
  end
end
