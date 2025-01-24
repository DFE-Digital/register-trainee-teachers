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
            expect(bulk_placement.rows.pluck(:trn, :csv_row_number, :urn)).to eql(
              [
                ["1234567", 3, "7823614827346"],
                ["1234567", 3, "723894747382"],
                ["7654321", 4, "8721398474987"],
                ["7654321", 4, "273489724897"],
              ],
            )
          end
        end

        context "given a valid CSV where user has added extra URN columns" do
          let(:file) { file_fixture("bulk_update/placements/complete-with-extra-placements.csv") }

          it "creates the rows with the correct row numbers" do
            expect(bulk_placement.rows.pluck(:trn, :csv_row_number, :urn)).to eql(
              [
                ["1234567", 3, "7823614827346"],
                ["1234567", 3, "723894747382"],
                ["7654321", 4, "8721398474987"],
                ["7654321", 4, "273489724897"],
                ["7654321", 4, "999745281883"],
                ["4929008", 5, "562982561839"],
                ["4929008", 5, "668741619393"],
                ["4929008", 5, "878892930276"],
                ["4929008", 5, "853226807662"],
              ],
            )
          end
        end

        context "given a csv with urns set as `ADDED MANUALLY`" do
          let(:trainees) { create_list(:trainee, 3, :trn_received, :with_manual_placements) }
          let(:csv) { [] }
          let(:generate_report) { ::Reports::BulkPlacementReport.new(csv, scope: trainees).generate_report }

          before do
            generate_report
            service
          end

          it "does not create placement rows" do
            expect(csv).not_to be_empty
            expect(bulk_placement.rows).to be_empty
          end
        end
      end
    end
  end
end
