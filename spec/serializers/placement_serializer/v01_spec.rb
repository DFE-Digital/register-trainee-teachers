# frozen_string_literal: true

require "rails_helper"

RSpec.describe PlacementSerializer::V01 do
  let(:placement) { create(:placement) }
  let(:json) { described_class.new(placement).as_hash.with_indifferent_access }

  describe "serialization" do
    it "includes all expected fields" do
      %w[
        placement_id
        urn
        name
        postcode
        created_at
        updated_at
      ].each do |field|
        expect(json.keys).to include(field)
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
        expect(json.keys).not_to include(field)
      end
    end
  end
end
