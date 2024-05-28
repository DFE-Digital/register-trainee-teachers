# frozen_string_literal: true

require "rails_helper"

describe Api::GetVersionedItem do
  describe "#for_service" do
    services = %w[map_hesa_attributes map_hesa_degree_attributes map_hesa_placement_attributes update_trainee]
    context "v0.1" do
      services.each do |service|
        it "#{service} has been implemented" do
          expect(described_class.for_service(model: service, version: "v0.1")).to be(Object.const_get("Api::#{service.camelize}Service::V01"))
        end
      end
    end

    context "v1.0" do
      services.each do |service|
        it "#{service} has not been implemented" do
          expect { described_class.for_service(model: service, version: "v1.0") }.to raise_error(NotImplementedError, "Api::#{service.camelize}Service::V10")
        end
      end
    end

    context "v0.1 not on the allowed versions" do
      before do
        allow(Settings.api).to receive(:allowed_versions).and_return([])
      end

      services.each do |service|
        it "#{service} has not been implemented" do
          expect { described_class.for_service(model: service, version: "v0.1") }.to raise_error(NotImplementedError, "Api::#{service.camelize}Service::V01")
        end
      end
    end
  end

  describe "#for_attribute" do
    attributes = %w[degree hesa_trainee_detail nationality placement trainee withdrawal trainee_filter_params]
    context "v0.1" do
      attributes.each do |attribute|
        it "#{attribute} has been implemented" do
          expect(described_class.for_attributes(model: attribute, version: "v0.1")).to be(Object.const_get("Api::#{attribute.camelize}_Attributes::V01".camelize))
        end
      end
    end

    context "v1.0" do
      attributes.each do |attribute|
        it "#{attribute} has not been implemented" do
          expect { described_class.for_attributes(model: attribute, version: "v1.0") }.to raise_error(NotImplementedError, "Api::#{attribute.camelize}_Attributes::V10".camelize)
        end
      end
    end

    context "v0.1 not on the allowed versions" do
      before do
        allow(Settings.api).to receive(:allowed_versions).and_return([])
      end

      attributes.each do |attribute|
        it "#{attribute} has not been implemented" do
          expect { described_class.for_attributes(model: attribute, version: "v0.1") }.to raise_error(NotImplementedError, "Api::#{attribute.camelize}_Attributes::V01".camelize)
        end
      end
    end
  end

  describe "#for_serializer" do
    serializers = %w[degree hesa_trainee_detail placement trainee]
    context "v0.1" do
      serializers.each do |serializer|
        it "#{serializer} has been implemented" do
          expect(described_class.for_serializer(model: serializer, version: "v0.1")).to be(Object.const_get("Api::#{serializer.camelize}Serializer::V01"))
        end
      end
    end

    context "v1.0" do
      serializers.each do |serializer|
        it "#{serializer} has not been implemented" do
          expect { described_class.for_serializer(model: serializer, version: "v1.0") }.to raise_error(NotImplementedError, "Api::#{serializer.camelize}Serializer::V10")
        end
      end
    end

    context "v0.1 not on the allowed versions" do
      before do
        allow(Settings.api).to receive(:allowed_versions).and_return([])
      end

      serializers.each do |serializer|
        it "#{serializer} has not been implemented" do
          expect { described_class.for_serializer(model: serializer, version: "v0.1") }.to raise_error(NotImplementedError, "Api::#{serializer.camelize}Serializer::V01")
        end
      end
    end
  end
end
