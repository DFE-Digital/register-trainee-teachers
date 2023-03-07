# frozen_string_literal: true

require "rails_helper"

module BulkUpdate
  module RecommendationsUploads
    describe ValidateFile do
      subject(:service) { described_class.new(file:, record:) }

      let(:record) { ::BulkUpdate::RecommendationsUploadForm.new }

      before { service.validate! }

      context "given a file that is empty" do
        let(:file) { double("file", size: 0) }

        it { expect(record.errors.first.message).to eql "File cannot be empty" }
      end

      context "given a file that is greater than 1MB" do
        let(:file) { double("file", size: 2.megabytes) }

        it { expect(record.errors.first.message).to eql "File must be no greater than 1MB" }
      end
    end
  end
end
