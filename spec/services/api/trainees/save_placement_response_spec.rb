# frozen_string_literal: true

require "rails_helper"

describe Api::Trainees::SavePlacementResponse do
  let(:placement_response) { described_class.call(placement:, attributes:, version:) }
  let(:attributes) do
    {}
  end
  let(:trainee) { create(:trainee, :with_placements) }
  let(:version) { "v2025.0-rc" }

  subject { placement_response }

  context "with a new placement" do
    let(:placement) { trainee.placements.new }

    context "with valid params" do
      let(:placement_attribute_keys) { Api::V20250Rc::PlacementAttributes::ATTRIBUTES.map(&:to_s).push("address") }

      let(:attributes) do
        attrs = create(:placement).attributes.slice(*placement_attribute_keys).with_indifferent_access
        Api::V20250Rc::PlacementAttributes.new(attrs)
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
        expect(Api::V20250Rc::PlacementSerializer).to receive(:new).with(placement).and_return(double(as_hash: placement.attributes)).at_least(:once)

        subject
      end
    end

    context "with invalid params" do
      let(:attributes) { Api::V20250Rc::PlacementAttributes.new({}) }

      it "returns status unprocessable entity with error response" do
        expect(subject[:status]).to be(:unprocessable_entity)
        expect(subject[:json][:data]).to be_blank
        expect(subject[:json][:errors]).to contain_exactly(
          { error: "UnprocessableEntity", message: "name can't be blank" },
        )
      end
    end
  end

  context "with an existing placement" do
    let(:placement) { trainee.placements.first }

    context "with valid params" do
      let(:placement_attribute_keys) { Api::V20250Rc::PlacementAttributes::ATTRIBUTES.map(&:to_s).push("address") }

      let(:attributes) do
        attrs = create(:placement).attributes.slice(*placement_attribute_keys).with_indifferent_access
        Api::V20250Rc::PlacementAttributes.new(attrs)
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
        expect(Api::V20250Rc::PlacementSerializer).to receive(:new).with(placement).and_return(double(as_hash: placement.attributes)).at_least(:once)

        subject
      end
    end

    context "with invalid params" do
      let(:attributes) { Api::V20250Rc::PlacementAttributes.new({}) }

      it "returns status unprocessable entity with error response" do
        expect(subject[:status]).to be(:unprocessable_entity)
        expect(subject[:json][:data]).to be_blank
        expect(subject[:json][:errors]).to contain_exactly(
          { error: "UnprocessableEntity", message: "name can't be blank" },
        )
      end
    end
  end
end
