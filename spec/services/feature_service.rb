require "rails_helper"

describe FeatureService do
  describe ".enabled?" do
    context "feature is enabled" do
      before do
        Settings.features[:some_feature] = true
      end

      it "returns true" do
        response = FeatureService.enabled?(:some_feature)

        expect(response).to be_truthy
      end
    end

    context "feature is disabled" do
      before do
        Settings.features[:some_feature] = false
      end

      it "returns false" do
        response = FeatureService.enabled?(:some_feature)

        expect(response).to be_falsey
      end
    end
  end
end
