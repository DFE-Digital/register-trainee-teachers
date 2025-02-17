# frozen_string_literal: true

require "rails_helper"

describe Api::Trainees::SavePlacementResponse do
  let(:placement_response) { described_class.call(placement:, attributes:, version:) }
  let(:attributes) do
    {}
  end
  let(:trainee) { create(:trainee, :with_placements) }
  let(:version) { "v0.1" }

  subject { placement_response }

  context "with a new placement" do
    let(:placement) { trainee.placements.new }

    context "with valid params" do
      let(:placement_attribute_keys) { Api::V01::PlacementAttributes::ATTRIBUTES.map(&:to_s).push("address") }

      let(:attributes) do
        attrs = create(:placement).attributes.slice(*placement_attribute_keys).with_indifferent_access
        Api::V01::PlacementAttributes.new(attrs)
      end

      it "returns status created with data" do
        expect(subject[:status]).to be(:created)
        expect(subject[:json][:data].slice(*placement_attribute_keys)).to match(
          "urn" => attributes.urn,
          "name" => attributes.name,
          "address" => "URN #{attributes.urn}, #{attributes.postcode}",
          "postcode" => attributes.postcode,
        )

        expect(placement.id).to be_present
        expect(placement.slug).to be_present
        expect(placement.school_id).to be_nil
      end

      it "uses the serializer" do
        expect(Api::V01::PlacementSerializer).to receive(:new).with(placement).and_return(double(as_hash: placement.attributes)).at_least(:once)

        subject
      end
    end

    context "with invalid params" do
      let(:attributes) { Api::V01::PlacementAttributes.new({}) }

      it "returns status unprocessable entity with error response" do
        expect(subject[:status]).to be(:unprocessable_entity)
        expect(subject[:json][:data]).to be_blank
        expect(subject[:json][:errors]).to contain_exactly(
          { error: "UnprocessableEntity", message: "Name can't be blank" },
        )
      end
    end
  end

  context "with an existing placement" do
    let(:placement) { trainee.placements.first }

    context "with valid params" do
      let(:placement_attribute_keys) { Api::V01::PlacementAttributes::ATTRIBUTES.map(&:to_s).push("address") }

      let(:attributes) do
        attrs = create(:placement).attributes.slice(*placement_attribute_keys).with_indifferent_access
        Api::V01::PlacementAttributes.new(attrs)
      end

      it "returns status ok with data" do
        expect(subject[:status]).to be(:ok)
        expect(subject[:json][:data].slice(*placement_attribute_keys)).to match(
          "urn" => attributes.urn,
          "name" => attributes.name,
          "address" => "URN #{attributes.urn}, #{attributes.postcode}",
          "postcode" => attributes.postcode,
        )

        expect(placement.reload.id).to be_present
        expect(placement.slug).to be_present
        expect(placement.school_id).to eq(attributes.school_id)
      end

      it "uses the serializer" do
        expect(Api::V01::PlacementSerializer).to receive(:new).with(placement).and_return(double(as_hash: placement.attributes)).at_least(:once)

        subject
      end
    end

    context "with invalid params" do
      let(:attributes) do
        Api::V01::PlacementAttributes.new({})
      end

      it "returns status unprocessable entity with error response" do
        expect(subject[:status]).to be(:unprocessable_entity)
        expect(subject[:json][:data]).to be_blank
        expect(subject[:json][:errors]).to contain_exactly(
          { error: "UnprocessableEntity", message: "Name can't be blank" },
        )
      end
    end
  end

  context "with a new but duplicate placement" do
    let(:trainee) { create(:trainee, placements: [existing_placement]) }
    let(:placement) { trainee.placements.new }

    let(:placement_attribute_keys) { Api::V01::PlacementAttributes::ATTRIBUTES.map(&:to_s) }

    let(:attributes) do
      attrs = existing_placement.attributes.slice(*placement_attribute_keys).with_indifferent_access
      Api::V01::PlacementAttributes.new(attrs)
    end

    context "with same name" do
      let(:existing_placement) { create(:placement, name: "existing placement") }

      it "returns status unprocessable entity with error response" do
        expect(subject[:status]).to be(:conflict)
        expect(subject[:json][:data]).to contain_exactly(
          Api::V01::PlacementSerializer.new(existing_placement).as_hash
        )
        expect(subject[:json][:errors]).to contain_exactly(
          error: "Conflict",
          message: "Urn has already been taken",
        )
      end
    end
  end
end
