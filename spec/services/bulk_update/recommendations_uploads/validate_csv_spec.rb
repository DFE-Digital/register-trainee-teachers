# frozen_string_literal: true

require "rails_helper"

module BulkUpdate
  module RecommendationsUploads
    describe ValidateCsv do
      subject(:service) { described_class.new(csv:, record:) }

      let(:csv) { CSV.new(file.read, headers: true).read }
      let(:record) { ::BulkUpdate::RecommendationsUploadForm.new }

      before { service.validate! }

      context "given a CSV with missing headers" do
        let(:file) { file_fixture("bulk_update/recommendations_upload/missing_required_header.csv") }

        it { expect(record.errors.first.message).to eql "CSV is missing the required headers" }
      end
    end
  end
end
