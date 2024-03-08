# frozen_string_literal: true

require "rails_helper"

describe Api::Trainees::SaveDegreeResponse do
  let(:degree_response) { described_class.call(degree:, params:, version:) }
  let(:params) do
    {}
  end
  let(:trainee) { create(:trainee, :with_degree) }
  let(:version) { "v01" }

  subject { degree_response }

  context "with a new degree" do
    let(:degree) { trainee.degrees.new }

    context "with valid params" do
      let(:degree_attribute_keys) { Api::DegreeAttributes::V01::ATTRIBUTES.map(&:to_s) }

      let(:params) do
        build(:degree).attributes.slice(*degree_attribute_keys).with_indifferent_access
      end

      it "returns status created with data" do
        expect(subject[:status]).to be(:created)

        expect(degree.reload.id).to be_present
        expect(degree.reload.slug).to be_present
      end

      it "uses the serializer" do
        expect(DegreeSerializer::V01).to receive(:new).with(degree).and_return(double(as_hash: degree.attributes)).at_least(:once)

        subject
      end

      it "uses the attributes" do
        expect(Api::DegreeAttributes::V01).to receive(:new).with(params).and_return(double(attributes: degree.attributes, valid?: true, errors: nil)).at_least(:once)

        subject
      end
    end

    context "with invalid params" do
      let(:params) { {} }

      it "returns status unprocessable entity with error response" do
        expect(subject[:status]).to be(:unprocessable_entity)
        expect(subject[:json][:data]).to be_blank
        expect(subject[:json][:errors]).to be_present
      end
    end
  end

  context "with an existing degree" do
    let(:degree) { trainee.degrees.first }

    context "with valid params" do
      let(:degree_attribute_keys) { Api::DegreeAttributes::V01::ATTRIBUTES.map(&:to_s) }

      let(:params) do
        create(:degree).attributes.slice(*degree_attribute_keys).with_indifferent_access
      end

      it "returns status ok with data" do
        expect(subject[:status]).to be(:ok)

        expect(degree.reload.id).to be_present
        expect(degree.reload.slug).to be_present
      end

      it "uses the serializer" do
        expect(DegreeSerializer::V01).to receive(:new).with(degree).and_return(double(as_hash: degree.attributes)).at_least(:once)

        subject
      end

      it "uses the attributes" do
        expect(Api::DegreeAttributes::V01).to receive(:new).with(params).and_return(double(attributes: degree.attributes, valid?: true, errors: nil)).at_least(:once)

        subject
      end
    end

    context "with invalid params" do
      let(:params) { {} }

      it "returns status unprocessable entity with error response" do
        expect(subject[:status]).to be(:unprocessable_entity)
        expect(subject[:json][:data]).to be_blank
        expect(subject[:json][:errors]).to be_present
      end
    end
  end
end
