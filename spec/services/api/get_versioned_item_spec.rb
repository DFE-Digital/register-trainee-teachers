# frozen_string_literal: true

require "rails_helper"

describe Api::GetVersionedItem do
  get_versioned_item = "get versioned item"

  shared_examples get_versioned_item do |item_type, item_models|
    wrapper_method = "for_#{item_type}"

    describe "#for" do
      context "v0.1" do
        item_models.each do |item_model|
          it "#{item_model} has been implemented" do
            expect(described_class.for(item_type: item_type.to_sym, model: item_model, version: "v0.1")).to be(Object.const_get("Api::#{item_model.camelize}#{item_type.camelize}::V01"))
          end
        end
      end
    end

    describe "##{wrapper_method}" do
      context "v0.1" do
        item_models.each do |item_model|
          it "#{item_model} has been implemented" do
            expect(described_class.public_send(wrapper_method, model: item_model, version: "v0.1")).to be(Object.const_get("Api::#{item_model.camelize}#{item_type.camelize}::V01"))
          end
        end
      end

      context "v1.0" do
        item_models.each do |item_model|
          it "#{item_model} has not been implemented" do
            expect { described_class.public_send(wrapper_method, model: item_model, version: "v1.0") }.to raise_error(NotImplementedError, "Api::#{item_model.camelize}#{item_type.camelize}::V10")
          end
        end
      end

      context "v0.1 not on the allowed versions" do
        before do
          allow(Settings.api).to receive(:allowed_versions).and_return([])
        end

        item_models.each do |item_model|
          it "#{item_model} has not been implemented" do
            expect { described_class.public_send(wrapper_method, model: item_model, version: "v0.1") }.to raise_error(NotImplementedError, "Api::#{item_model.camelize}#{item_type.camelize}::V01")
          end
        end
      end
    end
  end

  include_examples get_versioned_item, "service", %w[map_hesa_attributes map_hesa_degree_attributes map_hesa_placement_attributes update_trainee]
  include_examples get_versioned_item, "attributes", %w[degree hesa_trainee_detail nationality placement trainee withdrawal trainee_filter_params]
  include_examples get_versioned_item, "serializer", %w[degree hesa_trainee_detail placement trainee]
end
