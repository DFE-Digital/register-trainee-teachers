# frozen_string_literal: true

require "rails_helper"

describe Api::Trainees::SavePlacementResponse do
  let(:placement_response) { described_class.call(placement:, params:, version:) }
  let(:params) do
    {}
  end
  let(:trainee) { create(:trainee, :with_placements) }
  let(:version) { "v0.1" }

  subject { placement_response }

  context "with a new placement" do
    let(:placement) { trainee.placements.new }

    context "with valid params" do
      let(:placement_attribute_keys) { Api::V01::PlacementAttributes::ATTRIBUTES.map(&:to_s) }

      let(:params) do
        create(:placement).attributes.slice(*placement_attribute_keys).with_indifferent_access
      end

      it "returns status created with data" do
        expect(subject[:status]).to be(:created)
        expect(subject[:json][:data].slice(*placement_attribute_keys)).to match(
          "urn" => params[:urn],
          "name" => params[:name],
          "address" => "URN #{params[:urn]}, #{params[:address]}, #{params[:postcode]}",
          "postcode" => params[:postcode],
        )

        expect(placement.id).to be_present
        expect(placement.slug).to be_present
        expect(placement.school_id).to be_nil
      end

      it "uses the serializer" do
        expect(Api::V01::PlacementSerializer).to receive(:new).with(placement).and_return(double(as_hash: placement.attributes)).at_least(:once)

        subject
      end

      it "uses the attributes" do
        expect(Api::V01::PlacementAttributes).to receive(:new).with(params).and_return(double(attributes: placement.attributes, valid?: true, errors: nil)).at_least(:once)

        subject
      end
    end

    context "with invalid params" do
      let(:params) { {} }

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
      let(:placement_attribute_keys) { Api::V01::PlacementAttributes::ATTRIBUTES.map(&:to_s) }

      let(:params) do
        create(:placement).attributes.slice(*placement_attribute_keys).with_indifferent_access
      end

      it "returns status ok with data" do
        expect(subject[:status]).to be(:ok)
        expect(subject[:json][:data].slice(*placement_attribute_keys)).to match(
          "urn" => params[:urn],
          "name" => params[:name],
          "address" => "URN #{params[:urn]}, #{params[:address]}, #{params[:postcode]}",
          "postcode" => params[:postcode],
        )

        expect(placement.reload.id).to be_present
        expect(placement.slug).to be_present
        expect(placement.school_id).to eq(params[:school_id])
      end

      it "uses the serializer" do
        expect(Api::V01::PlacementSerializer).to receive(:new).with(placement).and_return(double(as_hash: placement.attributes)).at_least(:once)

        subject
      end

      it "uses the attributes" do
        expect(Api::V01::PlacementAttributes).to receive(:from_placement).with(placement).and_return(double(attributes: placement.attributes, assign_attributes: true, valid?: true, errors: nil)).at_least(:once)

        subject
      end
    end

    context "with invalid params" do
      let(:params) { { name: "", school_id: "" } }

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

    let(:params) do
      existing_placement.attributes.slice(*placement_attribute_keys).with_indifferent_access
    end

    context "with same name" do
      let(:existing_placement) { create(:placement, name: "existing placement") }

      it "returns status unprocessable entity with error response" do
        expect(subject[:status]).to be(:conflict)
        expect(subject[:json][:data]).to be_blank
        expect(subject[:json][:errors]).to include(
          { error: "Conflict", message: "Urn has already been taken" },
        )
      end
    end

    context "with same address and postcode" do
      let(:existing_placement) { create(:placement, address: "1 Hogwarts drive", postcode: "BN1 1AA") }

      it "returns status unprocessable entity with error response" do
        expect(subject[:status]).to be(:conflict)
        expect(subject[:json][:data]).to be_blank
        expect(subject[:json][:errors]).to include(
          { error: "Conflict", message: "Address has already been taken" },
        )
      end
    end
  end
end
