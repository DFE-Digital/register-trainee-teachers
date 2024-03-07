require "rails_helper"

RSpec.describe PlacementSerializer::V01 do
  let(:placement) { create(:placement) }
  let(:json) { described_class.new(placement).as_hash.with_indifferent_access }

  PLACEMENT_FIELDS = %i[
    urn
    name
    postcode
  ].freeze

  describe "serialization" do
    PLACEMENT_FIELDS.each do |field|
      it "serializes the #{field} field from the specification" do
        expect(json).to have_key(field)
      end
    end
  end
end
