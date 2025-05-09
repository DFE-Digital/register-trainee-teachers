# frozen_string_literal: true

require "rails_helper"

describe Api::GetVersionedItem do
  get_versioned_item = "get versioned item"

  shared_examples get_versioned_item do |item_type, item_models|
    wrapper_method = "for_#{item_type}"

    def expected_module(item_type, model)
      if item_type == :service
        if model == :map_hesa_attributes
          "HesaMapper::Attributes"
        elsif %i[degree placement].include?(model)
          "HesaMapper::#{model.to_s.camelize}Attributes".camelize
        else
          "#{model}_#{item_type.capitalize}".camelize
        end
      else
        "#{model}_#{item_type.capitalize}".camelize
      end
    end

    describe "#for" do
      context "v0.1" do
        item_models.each do |item_model|
          it "#{item_model} has been implemented" do
            expect(
              described_class.for(
                item_type: item_type.to_sym,
                model: item_model,
                version: "v0.1",
              ),
            ).to be(Object.const_get("Api::V01::#{expected_module(item_type, item_model)}"))
          end
        end
      end

      context "v2025.0-rc" do
        item_models.each do |item_model|
          it "#{item_model} has been implemented" do
            expect(
              described_class.for(
                item_type: item_type.to_sym,
                model: item_model,
                version: "v2025.0-rc",
              ),
            ).to be(Object.const_get("Api::V20250Rc::#{expected_module(item_type, item_model)}"))
          end
        end
      end
    end

    describe "##{wrapper_method}" do
      context "v0.1" do
        item_models.each do |item_model|
          it "#{item_model} has been implemented" do
            expect(described_class.public_send(wrapper_method, model: item_model, version: "v0.1")).to be(Object.const_get("Api::V01::#{expected_module(item_type, item_model)}"))
          end
        end
      end

      context "v2.0" do
        item_models.each do |item_model|
          it "#{item_model} has not been implemented" do
            expect { described_class.public_send(wrapper_method, model: item_model, version: "v2.0") }.to raise_error(NotImplementedError, "Api::V20::#{expected_module(item_type, item_model)}")
          end
        end
      end

      context "v0.1 not on the allowed versions" do
        before do
          allow(Settings.api).to receive(:allowed_versions).and_return([])
        end

        item_models.each do |item_model|
          it "#{item_model} has not been implemented" do
            expect { described_class.public_send(wrapper_method, model: item_model, version: "v0.1") }.to raise_error(NotImplementedError, "Api::V01::#{expected_module(item_type, item_model)}")
          end
        end
      end
    end
  end

  it_behaves_like get_versioned_item, :service, %i[map_hesa_attributes degree placement update_trainee]
  it_behaves_like get_versioned_item, :attributes, %i[degree hesa_trainee_detail nationality placement trainee withdrawal trainee_filter_params]
  it_behaves_like get_versioned_item, :serializer, %i[degree hesa_trainee_detail placement trainee]
end
