# frozen_string_literal: true

require "rails_helper"

module DfEReference
  describe DisabilitiesQuery do
    let(:data_set) { DfE::ReferenceData::EqualityAndDiversity::DISABILITIES_AND_HEALTH_CONDITIONS }

    describe ".all" do
      it "returns all disabilities" do
        expect(described_class.all).to eq(data_set.all)
      end
    end

    describe ".find_disability" do
      context "when filters include an ID" do
        let(:valid_id) { described_class::NO_DISABILITY_UUID }
        let(:invalid_id) { "invalid-uuid" }
        let(:filters_with_valid_id) { { id: valid_id } }
        let(:filters_with_invalid_id) { { id: invalid_id } }

        it "returns the disability with the matching ID" do
          expected_disability = data_set.one(valid_id)
          expect(described_class.find_disability(filters_with_valid_id)).to eq(expected_disability)
        end

        it "returns nil if no disability matches the ID" do
          expect(described_class.find_disability(filters_with_invalid_id)).to be_nil
        end
      end

      context "when filters do not include an ID" do
        let(:some_filter) { { some_filter: "some_value" } }
        let(:non_existent_filter) { { some_filter: "non_existent_value" } }

        it "returns the first disability matching the filters" do
          expected_disability = data_set.some(some_filter).first
          expect(described_class.find_disability(some_filter)).to eq(expected_disability)
        end

        it "returns nil if no disabilities match the filters" do
          expect(described_class.find_disability(non_existent_filter)).to be_nil
        end
      end

      context "when filters are empty" do
        let(:empty_filters) { {} }

        it "returns nil" do
          expect(described_class.find_disability(empty_filters)).to be_nil
        end
      end
    end
  end
end
