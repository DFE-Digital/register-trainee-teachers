# frozen_string_literal: true

require "rails_helper"

module BulkUpdate
  module RecommendationsUploads
    describe ValidateFile do
      subject(:service) { described_class.new(file:, record:) }

      let(:record) { ::BulkUpdate::RecommendationsUploadForm.new }
      let(:error_message) { record.errors.full_messages.first }

      let(:content) { "This is some text" }
      let(:file) do
        Tempfile.new.tap do |f|
          f.write(content)
          f.rewind
        end
      end

      after { file.close! }

      context "given a file that is empty" do
        before { file.truncate(0) } # Make the file empty

        it "adds the correct error message" do
          service.validate!
          expect(error_message).to include "The selected file is empty"
        end
      end

      context "given a file that is greater than 1MB" do
        before { file.write("a" * 2.megabytes) } # Make the file larger than 1MB

        it "adds the correct error message" do
          service.validate!
          expect(error_message).to include "The selected file must be smaller than 1MB"
        end
      end

      context "given a non-utf8 file type" do
        let(:content) { "This is some text".encode("Windows-1252") }

        it "adds the correct error message" do
          service.validate!
          expect(error_message).to include "File The uploaded file is in an unsupported file encoding (ISO-8859-2). Please upload a file with UTF-8 or ISO-8859-1 encoding."
        end
      end
    end
  end
end
