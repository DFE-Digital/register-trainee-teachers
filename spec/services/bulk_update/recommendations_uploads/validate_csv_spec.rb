# frozen_string_literal: true

require "rails_helper"

module BulkUpdate
  module RecommendationsUploads
    describe ValidateCsv do
      subject(:service) { described_class.new(csv) }

      let(:csv) { CSV.new(file.read, headers: true).read }

      describe "#valid?" do
        context "given a CSV with required headers" do
          let(:file) { file_fixture("bulk_update/recommendations_upload/complete.csv") }

          it { expect(service.valid?).to be true }
        end

        context "given a CSV with missing headers" do
          let(:file) { file_fixture("bulk_update/recommendations_upload/missing_required_header.csv") }

          it { expect(service.valid?).to be false }
        end
      end
    end
  end
end
