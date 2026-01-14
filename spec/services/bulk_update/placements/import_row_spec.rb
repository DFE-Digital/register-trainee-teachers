# frozen_string_literal: true

require "rails_helper"

module BulkUpdate
  module Placements
    RSpec.describe ImportRow do
      describe "#call" do
        let(:bulk_update_placement) { create(:bulk_update_placement, provider: trainee.provider) }
        let(:placement_row) { create(:bulk_update_placement_row, trn: trainee.trn, urn: school.urn, bulk_update_placement: bulk_update_placement) }
        let(:service) { described_class.call(placement_row) }
        let(:trainee) { create(:trainee, :trn_received) }
        let(:create_dupe_trainee) { create(:trainee, :trn_received, :without_placements, trn: trainee.trn) }
        let(:school) { create(:school) }

        before do
          allow(ValidateRow).to receive(:new).and_return(validator)
          allow(placement_row).to receive(:can_be_imported?).and_return(can_be_imported)
          create_dupe_trainee
        end

        context "when the row can be imported and is valid" do
          let(:can_be_imported) { true }
          let(:validator) { instance_double(ValidateRow, valid?: true, school: school) }

          it "creates a placement and updates the row state to imported" do
            expect { service }.to change { ::Placement.count }.by(1)
            expect(placement_row.imported?).to be true
          end

          it "creates a placement with a `school_id` but no `urn` or `name`" do
            service
            placement = ::Placement.last
            expect(placement.school_id).to eq(school.id)
            expect(placement.attributes[:urn]).to be_nil
            expect(placement.attributes[:name]).to be_nil
          end

          it "updates the correct trainee placement" do
            expect { service }.to change { trainee.placements.count }.by(1)
            expect(create_dupe_trainee.placements.count).to eq(0)
          end
        end

        context "when the row can be imported but is invalid" do
          let(:can_be_imported) { true }
          let(:validator) { instance_double(ValidateRow, valid?: false, error_messages: ["Error message"]) }

          it "records errors and updates the row state to failed" do
            expect { service }.not_to change { ::Placement.count }
            expect(placement_row.failed?).to be true
            expect(placement_row.row_error_messages).to match(/Error message/)
          end
        end

        context "when the row cannot be imported" do
          let(:can_be_imported) { false }
          let(:validator) { instance_double(ValidateRow, valid?: true, school: school) }

          it "does nothing" do
            expect { service }.not_to change { ::Placement.count }
            expect { service }.not_to change { placement_row.state }
          end
        end
      end
    end
  end
end
