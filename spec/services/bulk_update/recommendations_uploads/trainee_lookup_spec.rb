# frozen_string_literal: true

require "rails_helper"

module BulkUpdate
  module RecommendationsUploads
    describe TraineeLookup do
      let(:file) { file_fixture("bulk_update/recommendations_upload/complete.csv") }
      let(:csv) { CSV.new(file.read, headers: true, header_converters: :downcase, strip: true).read }
      let(:rows) do
        csv.filter_map do |row|
          next if row.any? { |cell| cell.include?(Reports::BulkRecommendReport::DO_NOT_EDIT) }

          Row.new(row)
        end
      end

      let(:trainee) do
        row = rows.sample
        create(:trainee,
               :trn_received,
               trn: row.trn,
               hesa_id: row.sanitised_hesa_id,
               trainee_id: row.provider_trainee_id)
      end

      subject { described_class.new(rows, trainee.provider) }

      it "returns the trainees with matching TRN" do
        expect(subject[trainee.trn]).to eq([trainee])
      end

      it "returns the trainees with matching HESA ID" do
        expect(subject[trainee.hesa_id]).to eq([trainee])
      end

      it "returns the trainees with matching Trainee ID" do
        expect(subject[trainee.trainee_id]).to eq([trainee])
      end
    end
  end
end
