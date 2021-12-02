# frozen_string_literal: true

require "rails_helper"

module Dttp
  module Parsers
    describe PlacementAssignment do
      describe "#to_attributes" do
        let(:placement_assignment) { create(:api_placement_assignment) }

        let(:expected_attributes) do
          {
            dttp_id: placement_assignment["dfe_placementassignmentid"],
            contact_dttp_id: placement_assignment["_dfe_contactid_value"],
            response: placement_assignment,
          }
        end

        subject { described_class.to_attributes(placement_assignments: [placement_assignment]) }

        it "returns an array of Dttp::PlacementAssignment attributes" do
          expect(subject).to eq([expected_attributes])
        end
      end
    end
  end
end
