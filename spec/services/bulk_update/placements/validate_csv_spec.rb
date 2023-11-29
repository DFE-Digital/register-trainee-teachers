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
    end
  end
end
