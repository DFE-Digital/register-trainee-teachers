# frozen_string_literal: true

require "rails_helper"

module BulkUpdate
  module Placements
    RSpec.describe ImportRowJob do
      describe "#perform" do
        let(:placement_row) { create(:bulk_update_placement_row) }
        let(:job) { described_class.new }

        context "when the import is successful" do
          before do
            allow(ImportRow).to receive(:call).with(placement_row)
          end

          it "calls the ImportRow service with the placement_row" do
            job.perform(placement_row)
            expect(ImportRow).to have_received(:call).with(placement_row)
          end
        end

        context "when the import raises an error" do
          let(:error) { StandardError.new("runtime error") }

          before do
            allow(ImportRow).to receive(:call).with(placement_row).and_raise(error)
            allow(placement_row).to receive(:failed!)
            allow(placement_row.row_errors).to receive(:create)
          end

          it "rescues the error, marks the row as failed, and records the error message" do
            expect { job.perform(placement_row) }.to raise_error(StandardError)
            expect(placement_row).to have_received(:failed!)
            expect(placement_row.row_errors).to have_received(:create).with(message: "runtime failure: #{error.message}")
          end
        end
      end
    end
  end
end
