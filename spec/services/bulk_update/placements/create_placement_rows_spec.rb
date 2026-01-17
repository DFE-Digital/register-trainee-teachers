# frozen_string_literal: true

require "rails_helper"

module BulkUpdate
  module Placements
    describe CreatePlacementRows do
      let(:csv) { CSV.new(file.read, headers: true, header_converters: :downcase, strip: true).read }
      let(:bulk_placement) { create(:bulk_update_placement) }
      let(:provider) { bulk_placement.provider }

      describe "#call" do
        subject(:service) { described_class.call(bulk_placement:, csv:) }

        context "given a valid CSV" do
          before { service }

          let(:file) { file_fixture("bulk_update/placements/complete.csv") }

          it "creates the rows with the correct row numbers" do
            expect(bulk_placement.rows.pluck(:trn, :csv_row_number, :urn)).to eql(
              [
                ["1234567", 3, "100000"],
                ["1234567", 3, "100001"],
                ["7654321", 4, "100002"],
                ["7654321", 4, "100003"],
              ],
            )
          end
        end

        context "given a valid CSV where user has added extra URN columns" do
          before { service }

          let(:file) { file_fixture("bulk_update/placements/complete-with-extra-placements.csv") }

          it "creates the rows with the correct row numbers" do
            expect(bulk_placement.rows.pluck(:trn, :csv_row_number, :urn)).to eql(
              [
                ["1234567", 3, "100000"],
                ["1234567", 3, "100001"],
                ["7654321", 4, "100002"],
                ["7654321", 4, "100003"],
                ["7654321", 4, "100004"],
                ["4929008", 5, "100005"],
                ["4929008", 5, "100006"],
                ["4929008", 5, "100007"],
                ["4929008", 5, "100008"],
              ],
            )
          end
        end

        context "given a csv with urns set as `ADDED MANUALLY`" do
          let(:trainees) { create_list(:trainee, 3, :trn_received, :with_manual_placements) }
          let(:raw_csv) { [] }
          let(:csv) { CSV.new(raw_csv.to_s, headers: true, header_converters: :downcase, strip: true).read }
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
