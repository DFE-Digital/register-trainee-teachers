# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V20261::PlacementSerializer do
  shared_examples_for "a placement serialiser" do
    let(:fields) do
      %w[
        placement_id
        urn
        name
        address
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
  end
end
