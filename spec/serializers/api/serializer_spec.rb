# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::Serializer do
  serializers = %w[degree hesa_trainee_detail placement trainee]
  context "v0.1" do
    serializers.each do |serializer|
      it "#{serializer} has been implemented" do
        expect(described_class.for(model: serializer, version: "v0.1")).to be(Object.const_get("Api::#{serializer.camelize}Serializer::V01"))
      end
    end
  end

  context "v1.0" do
    serializers.each do |serializer|
      it "#{serializer} has not been implemented" do
        expect { described_class.for(model: serializer, version: "v1.0") }.to raise_error(NotImplementedError, "Api::#{serializer.camelize}Serializer::V10")
      end
    end
  end

  context "v0.1 not on the allowed versions" do
    before do
      allow(Settings.api).to receive(:allowed_versions).and_return([])
    end

    serializers.each do |serializer|
      it "#{serializer} has not been implemented" do
        expect { described_class.for(model: serializer, version: "v0.1") }.to raise_error(NotImplementedError, "Api::#{serializer.camelize}Serializer::V01")
      end
    end
  end
end
