# frozen_string_literal: true

require "rails_helper"

describe Api::GetVersionedItem do
  shared_examples "get versioned item" do |item_type, item_models|
    let(:wrapper_method) { "for_#{item_type}" }

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
      context "v2025.0" do
        item_models.each do |item_model|
          it "#{item_model} has been implemented" do
            expect(
              described_class.for(
                item_type: item_type.to_sym,
                model: item_model,
                version: "v2025.0",
              ),
            ).to be(Object.const_get("Api::V20250::#{expected_module(item_type, item_model)}"))
          end
        end
      end
    end

    describe "#for_#{item_type}" do
      context "v2025.0" do
        item_models.each do |item_model|
          it "#{item_model} has been implemented" do
            expect(described_class.public_send(wrapper_method, model: item_model, version: "v2025.0")).to be(Object.const_get("Api::V20250::#{expected_module(item_type, item_model)}"))
          end
        end
      end

      context "v2025.0 not on the allowed versions" do
        before do
          allow(Settings.api).to receive(:allowed_versions).and_return([])
        end

        item_models.each do |item_model|
          it "#{item_model} has not been implemented" do
            expect { described_class.public_send(wrapper_method, model: item_model, version: "v2025.0") }.to raise_error(NotImplementedError, "Api::V20250::#{expected_module(item_type, item_model)}")
          end
        end
      end
    end
  end

  it_behaves_like "get versioned item", :service, %i[map_hesa_attributes degree placement update_trainee]
  it_behaves_like "get versioned item", :attributes, %i[degree hesa_trainee_detail nationality placement trainee withdrawal trainee_filter_params]
  it_behaves_like "get versioned item", :serializer, %i[degree hesa_trainee_detail placement trainee]
end
