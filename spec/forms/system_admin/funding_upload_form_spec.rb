# frozen_string_literal: true

require "rails_helper"

module SystemAdmin
  describe FundingUploadForm, type: :model do
    subject { described_class.new }

    it { is_expected.to validate_presence_of(:funding_type) }
    it { is_expected.to validate_presence_of(:month) }
    it { is_expected.to validate_presence_of(:file) }

    describe "#save!" do
      subject do
        described_class.new(
          funding_type: "provider_payment_schedule",
          month: 1,
          file: Rack::Test::UploadedFile.new(csv_file.path, "text/csv"),
        )
      end

      let(:csv_file) do
        Tempfile.new(["funding", ".csv"]).tap do |tempfile|
          tempfile.write("﻿Academic year,Provider ID\n")
          tempfile.rewind
        end
      end

      context "when the file starts with a BOM" do
        it "saves the csv data without the BOM" do
          subject.save!

          expect(subject.funding_upload.csv_data).to start_with("Academic year")
        end
      end
    end
  end
end
