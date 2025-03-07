# frozen_string_literal: true

require "rails_helper"

module BulkUpdate
  module Placements
    RSpec.describe ImportRows do
      describe "#call" do
        let(:bulk_update_placement) { create(:bulk_update_placement) }
        let(:provider) { bulk_update_placement.provider }

        let(:school_one) { create(:school) }
        let(:school_two) { create(:school) }

        context "when there is a valid trainee for each row" do
          let(:trainee_one) { create(:trainee, :trn_received, provider:) }
          let(:trainee_two) { create(:trainee, :trn_received, provider:) }

          context "with urns of different schools" do
            let(:trainee_one_placement_row_one) do
              create(
                :bulk_update_placement_row,
                bulk_update_placement: bulk_update_placement,
                trn: trainee_one.trn,
                school: school_one,
                csv_row_number: 1,
              )
            end

            let(:trainee_two_placement_row_two) do
              create(
                :bulk_update_placement_row,
                bulk_update_placement: bulk_update_placement,
                trn: trainee_two.trn,
                school: school_two,
                csv_row_number: 2,
              )
            end

            before do
              trainee_one_placement_row_one
              trainee_two_placement_row_two
            end

            it "imports rows without errors" do
              described_class.call(bulk_update_placement)

              expect(trainee_one.placements.count).to eq(1)
              expect(trainee_one.placements.where(school: school_one).count).to eq(1)

              expect(trainee_two.placements.count).to eq(1)
              expect(trainee_two.placements.where(school: school_two).count).to eq(1)
            end

            context "when attempting to import the same placements" do
              let(:bulk_update_placement_two) { create(:bulk_update_placement, provider:) }

              let(:trainee_one_placement_row_three) do
                create(
                  :bulk_update_placement_row,
                  bulk_update_placement: bulk_update_placement_two,
                  trn: trainee_one.trn,
                  school: school_one,
                  csv_row_number: 1,
                )
              end

              let(:trainee_two_placement_row_four) do
                create(
                  :bulk_update_placement_row,
                  bulk_update_placement: bulk_update_placement_two,
                  trn: trainee_two.trn,
                  school: school_two,
                  csv_row_number: 2,
                )
              end

              before do
                trainee_one_placement_row_one
                trainee_two_placement_row_two

                trainee_one_placement_row_three
                trainee_two_placement_row_four
              end

              it "imports rows without errors and replaces any existing placements" do
                expect {
                  described_class.call(bulk_update_placement)
                }.to change { trainee_one.placements.count }.from(0).to(1)
                  .and change { trainee_one.placements.where(school: school_one).count }.by(1)
                  .and change { trainee_two.placements.count }.from(0).to(1)
                  .and change { trainee_two.placements.where(school: school_two).count }.by(1)

                expect {
                  described_class.call(bulk_update_placement_two)
                }.to not_change { trainee_one.placements.count }
                  .and not_change { trainee_one.placements.where(school: school_one).count }
                  .and not_change { trainee_two.placements.count }
                  .and not_change { trainee_two.placements.where(school: school_two).count }
              end
            end
          end

          context "with urns of the same school" do
            let(:trainee_one_placement_row_one) do
              create(
                :bulk_update_placement_row,
                bulk_update_placement: bulk_update_placement,
                trn: trainee_one.trn,
                school: school_one,
                csv_row_number: 1,
              )
            end

            let(:trainee_two_placement_row_two) do
              create(
                :bulk_update_placement_row,
                bulk_update_placement: bulk_update_placement,
                trn: trainee_one.trn,
                school: school_one,
                csv_row_number: 2,
              )
            end

            let(:trainee_two_placement_row_three) do
              create(
                :bulk_update_placement_row,
                bulk_update_placement: bulk_update_placement,
                trn: trainee_two.trn,
                school: school_two,
                csv_row_number: 3,
              )
            end

            before do
              trainee_one_placement_row_one
              trainee_two_placement_row_two
              trainee_two_placement_row_three
            end

            it "imports rows without errors" do
              expect {
                described_class.call(bulk_update_placement)
              }.to change { trainee_one.placements.count }.from(0).to(2)
                .and change { trainee_one.placements.where(school: school_one).count }.by(2)
                .and change { trainee_two.placements.count }.from(0).to(1)
                .and change { trainee_two.placements.where(school: school_two).count }.by(1)
            end

            context "when attempting to import the same placements" do
              let(:bulk_update_placement_two) { create(:bulk_update_placement, provider:) }

              let(:trainee_one_placement_row_three) do
                create(
                  :bulk_update_placement_row,
                  bulk_update_placement: bulk_update_placement_two,
                  trn: trainee_one.trn,
                  school: school_one,
                  csv_row_number: 1,
                )
              end

              let(:trainee_two_placement_row_four) do
                create(
                  :bulk_update_placement_row,
                  bulk_update_placement: bulk_update_placement_two,
                  trn: trainee_one.trn,
                  school: school_one,
                  csv_row_number: 2,
                )
              end

              let(:trainee_two_placement_row_five) do
                create(
                  :bulk_update_placement_row,
                  bulk_update_placement: bulk_update_placement_two,
                  trn: trainee_two.trn,
                  school: school_two,
                  csv_row_number: 3,
                )
              end

              before do
                trainee_one_placement_row_one
                trainee_two_placement_row_two
                trainee_one_placement_row_three
                trainee_two_placement_row_four
                trainee_two_placement_row_five
              end

              it "imports rows without errors and replaces any existing placements" do
                expect {
                  described_class.call(bulk_update_placement)
                }.to change { trainee_one.placements.count }.from(0).to(2)
                  .and change { trainee_one.placements.where(school: school_one).count }.by(2)
                  .and change { trainee_two.placements.count }.from(0).to(1)
                  .and change { trainee_two.placements.where(school: school_two).count }.by(1)

                expect {
                  described_class.call(bulk_update_placement_two)
                }.to not_change { trainee_one.placements.count }
                  .and not_change { trainee_one.placements.where(school: school_one).count }
                  .and not_change { trainee_two.placements.count }
                  .and not_change { trainee_two.placements.where(school: school_one).count }
              end
            end
          end
        end

        context "when there are no trainees found for a TRN" do
          let(:trns) { ["bad trn", "1120932038"] }
          let(:rows) { bulk_update_placement.rows }

          before do
            create_rows_for_bulk_placement(trns)

            allow(ImportRow).to receive(:call)
          end

          it "marks rows as failed and adds error messages" do
            described_class.call(bulk_update_placement)

            expect(ImportRow).to have_received(:call).exactly(0).times

            check_rows_for_errors("No trainee was found for TRN:", "failed")
          end
        end

        context "when there are multiple trainees for a TRN" do
          let(:trns) { %w[1234567 1234567] }
          let(:rows) { bulk_update_placement.rows }

          before do
            create_rows_for_bulk_placement(trns)
            create_list(:trainee, 2, trn: "1234567", provider: provider)

            allow(ImportRow).to receive(:call)
          end

          it "marks rows as failed and adds error messages" do
            described_class.call(bulk_update_placement)

            expect(ImportRow).to have_received(:call).exactly(0).times

            check_rows_for_errors("More than one trainee was found for TRN:", "failed")
          end
        end

        context "when importing a row raises an error" do
          let(:trainees) { create_list(:trainee, 2, :trn_received, provider:) }
          let(:trns) { trainees.map(&:trn) }
          let(:rows) { bulk_update_placement.rows }
          let(:error) { StandardError.new("runtime error") }

          before do
            create_rows_for_bulk_placement(trns)

            allow(ImportRow).to receive(:call).and_raise(error)
          end

          it "rescues the error, marks the row as failed, and records the error message" do
            described_class.call(bulk_update_placement)

            expect(ImportRow).to have_received(:call).exactly(trns.size).times

            check_rows_for_errors("runtime failure: #{error.message}", "failed")
          end
        end
      end

      def create_rows_for_bulk_placement(trns)
        trns.each_with_index do |trn, csv_row_number|
          create(:bulk_update_placement_row, bulk_update_placement:, trn:, csv_row_number:)
        end
      end

      def check_rows_for_errors(expected_error_message, expected_state)
        expect(rows.count).to eql trns.size
        rows.each do |row|
          expect(row.row_error_messages).to match(expected_error_message)
          expect(row.state).to eql expected_state
        end
      end
    end
  end
end
