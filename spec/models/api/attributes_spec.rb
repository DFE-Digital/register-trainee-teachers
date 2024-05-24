# frozen_string_literal: true

require "rails_helper"

describe Api::Attributes do
  attributes = %i[degree hesa_trainee_detail nationality placement trainee map_hesa withdrawal]
  context "v0.1" do
    attributes.each do |attribute|
      it "#{attribute} has been implemented" do
        expect(described_class.for(model: attribute, version: "v0.1")).to be(Object.const_get("Api::#{attribute.to_s.camelize}_Attributes::V01".camelize))
      end
    end
  end

  context "v1.0" do
    attributes.each do |attribute|
      it "#{attribute} has not been implemented" do
        expect { described_class.for(model: attribute, version: "v1.0") }.to raise_error(NotImplementedError, "Api::#{attribute.to_s.camelize}_Attributes::V10".camelize)
      end
    end
  end

  context "v0.1 not on the allowed versions" do
    before do
      allow(Settings.api).to receive(:allowed_versions).and_return([])
    end

    attributes.each do |attribute|
      it "#{attribute} has not been implemented" do
        expect { described_class.for(model: attribute, version: "v0.1") }.to raise_error(NotImplementedError, "Api::#{attribute.to_s.camelize}_Attributes::V01".camelize)
      end
    end
  end
end
