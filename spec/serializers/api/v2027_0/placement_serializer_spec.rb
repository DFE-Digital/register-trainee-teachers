# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V20270::PlacementSerializer do
  shared_examples_for "a placement serialiser" do
    let(:fields) do
      %w[
        placement_id
        urn
        name
        address
        address_line_one
        address_line_two
        town_city
        postcode
        created_at
        updated_at
      ]
    end

    it "matches the fields" do
      expect(json.keys).to match_array(fields)
    end
  end

  describe "serialization" do
    let(:json) { described_class.new(placement).as_hash.with_indifferent_access }

    context "for a placement that is not associated with a school" do
      let(:placement) { create(:placement) }

      it_behaves_like "a placement serialiser"
    end

    context "for a placement that is associated with a school" do
      let(:placement) { create(:placement, :with_school) }

      it_behaves_like "a placement serialiser"
    end

    context "for a placement with an address entered one line at a time" do
      let(:placement) { create(:placement, urn: nil, address: "14 Mill Lane\n\nOxford", postcode: "OX3 9DU") }

      it "returns each line and the full address" do
        expect(json).to include(
          address: "14 Mill Lane, Oxford, OX3 9DU",
          address_line_one: "14 Mill Lane",
          address_line_two: nil,
          town_city: "Oxford",
        )
      end
    end
  end
end
