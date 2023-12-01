# frozen_string_literal: true

require "rails_helper"

module BulkUpdate
  module Placements
    describe CreatePlacementRows do
      subject(:service) { described_class.call(bulk_placement:, csv:) }

      let(:csv) { CSV.new(file.read, headers: true, header_converters: :downcase, strip: true).read }
      let(:bulk_placement) { create(:bulk_update_placement) }
      let(:provider) { bulk_placement.provider }

      before { service }

      describe "#call" do
        context "given a valid CSV" do
          let(:file) { file_fixture("bulk_update/placements/complete.csv") }

          it "creates the rows with the correct row numbers" do
            expect(provider.placement_rows.pluck(:trn, :csv_row_number, :urn)).to eql(
              [
                ["1234567", 3, "7823614827346"],
                ["1234567", 3, "723894747382"],
                ["7654321", 4, "8721398474987"],
                ["7654321", 4, "273489724897"],
              ],
            )
          end
        end
      end
    end
  end
end
