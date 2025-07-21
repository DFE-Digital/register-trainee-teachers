# frozen_string_literal: true

require "rails_helper"

module BulkUpdate
  module RecommendationsUploads
    describe ValidateCsv do
      include RecommendationsUploadHelper

      subject(:service) { described_class.new(csv:, record:) }

      let(:record) { ::BulkUpdate::RecommendationsUploadForm.new }
      let(:csv) { create_recommendations_upload_csv!(columns_to_delete:) }

      before do
        create(:trainee, :bulk_recommend_from_hesa)
        service.validate!
      end

      context "given a CSV with no header row" do
        let(:csv) { CSV.new("", **Config::CSV_ARGS).read }

        it { expect(record.errors.first.message).to eql "No header was detected" }
      end

      context "given a CSV with a missing identifying header" do
        let(:columns_to_delete) { Reports::BulkRecommendReport::IDENTIFIERS.map(&:downcase) }

        it { expect(record.errors.first.message).to eql "The selected file must contain a column for TRN, trainee provider ID or HESA ID" }
      end

      context "given a CSV with no date header" do
        let(:columns_to_delete) { [Reports::BulkRecommendReport::DATE.downcase] }

        it { expect(record.errors.first.message).to eql "The selected file must contain a column for date QTS or EYTS requirement met" }
      end

      context "given a CSV with no dates" do
        let(:csv) { create_recommendations_upload_csv! }

        it { expect(record.errors.first.message).to eql "The selected file must contain date QTS or EYTS requirement met for at least one trainee" }
      end

      context "given a CSV with only headers, no trainees" do
        let(:headers) { Reports::BulkRecommendReport::DEFAULT_HEADERS.join(",") }
        let(:csv) { CSV.new(headers, **Config::CSV_ARGS).read }

        it { expect(record.errors.first.message).to eql "The selected file must contain at least one trainee" }
      end

      context "given a CSV with headers and 'No trainee data to export'" do
        let(:csv) { create_recommendations_upload_csv!(trainees: []) }

        it { expect(record.errors.first.message).to eql "The selected file must contain at least one trainee" }
      end
    end
  end
end
