# frozen_string_literal: true

require "rails_helper"

module BulkUpdate
  module Placements
    RSpec.describe ImportRows do
      describe "#call" do
        let(:bulk_update_placement) { create(:bulk_update_placement) }
        let(:service) { described_class.call(bulk_update_placement) }
        let(:provider) { bulk_update_placement.provider }
        let(:rows) { bulk_update_placement.rows.includes(:row_errors) }

        before do
          create_rows_for_bulk_placement(trns)
          allow(ImportRow).to receive(:call)
        end

        context "when there is a valid trainee for each row" do
          let(:trainees) { create_list(:trainee, 2, :trn_received, provider:) }
          let(:trns) { trainees.map(&:trn) }

          before { service }

          it "imports rows without errors" do
            expect(ImportRow).to have_received(:call).exactly(trns.size).times
          end
        end

        context "when there are no trainees found for a TRN" do
          let(:trns) { ["bad trn", "1120932038"] }

          before { service }

          it "marks rows as failed and adds error messages" do
            expect(ImportRow).to have_received(:call).exactly(0).times
            check_rows_for_errors("No trainee was found for TRN:", "failed")
          end
        end

        context "when there are multiple trainees for a TRN" do
          let(:trns) { %w[1234567 1234567] }

          before do
            create_list(:trainee, 2, trn: "1234567", provider: provider)
            service
          end

          it "marks rows as failed and adds error messages" do
            expect(ImportRow).to have_received(:call).exactly(0).times
            check_rows_for_errors("More than one trainee was found for TRN:", "failed")
          end
        end

        context "when importing a row raises an error" do
          let(:trainees) { create_list(:trainee, 2, :trn_received, provider:) }
          let(:trns) { trainees.map(&:trn) }
          let(:error) { StandardError.new("runtime error") }

          before do
            allow(ImportRow).to receive(:call).and_raise(error)
            service
          end

          it "rescues the error, marks the row as failed, and records the error message" do
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
