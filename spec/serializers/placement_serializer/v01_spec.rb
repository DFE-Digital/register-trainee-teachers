# frozen_string_literal: true

require "rails_helper"

RSpec.describe PlacementSerializer::V01 do
  let(:placement) { create(:placement) }
  let(:json) { described_class.new(placement).as_hash.with_indifferent_access }

  let(:expected_fields) do
    %i[
      urn
      name
      postcode
    ].freeze
  end

  describe "serialization" do
    expected_fields.each do |field|
      it "serializes the #{field} field from the specification" do
        expect(json).to have_key(field)
      end
    end
  end
end
