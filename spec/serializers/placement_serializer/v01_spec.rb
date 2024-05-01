# frozen_string_literal: true

require "rails_helper"

RSpec.describe PlacementSerializer::V01 do
  shared_examples_for "a placement serialiser" do
    it "includes all expected fields and they all have values" do
      %w[
        placement_id
        urn
        name
        postcode
        created_at
        updated_at
      ].each do |field|
        expect(json.keys).to include(field), "Expected key '#{field}' to be present, but it was not"
        expect(json[field]).to be_present, "Expected field '#{field}' to have a value, but it was '#{json[field]}'"
      end
    end

    it "does not include excluded fields" do
      %w[
        id
        slug
        trainee_id
        school_id
        address
      ].each do |field|
        expect(json.keys).not_to include(field), "Expected key '#{field}' NOT to be present, but it was not"
      end
    end
  end

  describe "serialization" do
    let(:json) { described_class.new(placement).as_hash.with_indifferent_access }

    context "for a placement that is not associated with a school" do
      let(:placement) { create(:placement, :manual) }

      it_behaves_like "a placement serialiser"
    end

    context "for a placement that is associated with a school" do
      let(:placement) { create(:placement, :with_school) }

      it_behaves_like "a placement serialiser"
    end
  end
end
