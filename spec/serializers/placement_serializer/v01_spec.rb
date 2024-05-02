# frozen_string_literal: true

require "rails_helper"

RSpec.describe PlacementSerializer::V01 do
  shared_examples_for "a placement serialiser" do
    %w[
      placement_id
      urn
      name
      postcode
      created_at
      updated_at
    ].each do |field|
      it "`#{field}` is present in the output and has a value" do
        expect(json.keys).to include(field)
        expect(json[field]).to be_present
      end
    end

    %w[
      id
      slug
      trainee_id
      school_id
      address
    ].each do |field|
      it "`#{field}` is not present in the output" do
        expect(json.keys).not_to include(field)
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
