# frozen_string_literal: true

require "rails_helper"

module BulkUpdate
  module Placements
    describe ValidateCsv do
      include PlacementsUploadHelper

      subject(:service) { described_class.new(csv:, record:) }

      let(:record) { ::BulkUpdate::PlacementsForm.new }
      let(:csv) { create_placements_upload_csv! }

      before do
        create(:academic_cycle, one_before_previous_cycle: true)
        create(:academic_cycle, previous_cycle: true)
        create(:trainee, :without_required_placements)
        service.validate!
      end

      context "given a CSV with no header row" do
        let(:csv) { CSV.new("", **Config::CSV_ARGS).read }

        it { expect(record.errors.first.message).to eql "CSV header must include: TRN, Trainee ITT start date, Placement 1 URN, Placement 2 URN" }
      end

      context "given a CSV with too many placement columns" do
        let(:file) { file_fixture("bulk_update/placements/complete-with-too-many-placements.csv") }
        let(:csv) { CSV.new(file.read, headers: true, header_converters: :downcase, strip: true).read }
        let(:expected_error_message) { "CSV header must include: TRN, Trainee ITT start date, Placement 1 URN, Placement 2 URN" }

        it { expect(record.errors.first.message).to eql expected_error_message }
      end

      context "given a CSV with some optional placement columns" do
        let(:file) { file_fixture("bulk_update/placements/complete-with-extra-placements.csv") }
        let(:csv) { CSV.new(file.read, headers: true, header_converters: :downcase, strip: true).read }

        it { expect(record.errors).to be_empty }
      end
    end
  end
end
