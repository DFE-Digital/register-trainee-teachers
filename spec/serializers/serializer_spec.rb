# frozen_string_literal: true

require "rails_helper"

RSpec.describe Serializer do
  serializers = %i[degree hesa_trainee_detail placement trainee]
  context "v0.1" do
    serializers.each do |serializer|
      it "#{serializer} has been implemented" do
        expect(described_class.for(model: serializer, version: "v0.1")).to be(Object.const_get("#{serializer}_Serializer::V01".camelize))
      end
    end
  end

  context "v1.0" do
    serializers.each do |serializer|
      it "#{serializer} has not been implemented" do
        expect { described_class.for(model: serializer, version: "v1.0") }.to raise_error(NotImplementedError, "#{serializer}_Serializer::V10".camelize)
      end
    end
  end

  context "v0.1 not on the allowed versions" do
    before do
      allow(Settings.api).to receive(:allowed_versions).and_return([])
    end

    serializers.each do |serializer|
      it "#{serializer} has not been implemented" do
        expect { described_class.for(model: serializer, version: "v0.1") }.to raise_error(NotImplementedError, "#{serializer}_Serializer::V01".camelize)
      end
    end
  end
end
