# frozen_string_literal: true

require "rails_helper"

module Hesa
  describe UploadTrnFile do
    describe ".call" do
      let(:trainee) { create(:trainee, :imported_from_hesa) }
      let(:file) { OpenStruct.new }
      let(:hesa_response) { double(code: "200", body: "True") }
      let(:url) { "#{Settings.hesa.trn_file_base_url}/#{Settings.hesa.current_collection_reference}" }

      before do
        allow(Hesa::TrnSubmission).to receive(:last_submitted_at).and_return(1.minute.ago)
        allow(Mechanize::Form::FileUpload).to receive(:new).with({ "name" => "file" }, "trn_file.csv").and_return(file)
      end

      it "builds a CSV of TRN data and uploads it as a file to HESA" do
        expect(Hesa::Client).to receive(:upload_trn_file).with(url: url, file: file).and_return(hesa_response)

        expect(described_class.call(trainees: [trainee])).to eq(file.file_data)
      end
    end
  end
end
