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
               provider_trainee_id: row.provider_trainee_id)
      end

      subject { described_class.new(rows, trainee.provider) }

      it "returns the trainees with matching TRN" do
        expect(subject[trainee.trn]).to eq([trainee])
      end

      it "returns the trainees with matching HESA ID" do
        expect(subject[trainee.hesa_id]).to eq([trainee])
      end

      it "returns the trainees with matching Trainee ID" do
        expect(subject[trainee.provider_trainee_id]).to eq([trainee])
      end

      context "when a discarded trainee exists with the same TRN" do
        let!(:discarded_trainee) do
          create(:trainee, :discarded, trn: trainee.trn, provider: trainee.provider)
        end

        it "excludes the discarded trainee from results" do
          expect(subject[trainee.trn]).to eq([trainee])
          expect(subject[trainee.trn]).not_to include(discarded_trainee)
        end
      end
    end
  end
end
