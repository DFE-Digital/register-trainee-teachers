# frozen_string_literal: true

require "rails_helper"

describe TrainingRouteManager do
  subject { described_class.new(trainee) }

  describe "#requires_placement_details?" do
    context "with the :routes_provider_led feature flag enabled" do
      before do
        allow(FeatureService).to receive(:enabled?).with(:routes_provider_led).and_return(true)
      end

      context "with a provider-led trainee" do
        let(:trainee) { build(:trainee, :provider_led) }

        it "returns true" do
          expect(subject.requires_placement_details?).to be true
        end
      end

      context "with a non provider-led trainee" do
        let(:trainee) { build(:trainee) }

        it "returns false" do
          expect(subject.requires_placement_details?).to be false
        end
      end
    end

    context "with the :routes_provider_led feature flag disabled" do
      let(:trainee) { build(:trainee, :provider_led) }

      before do
        allow(FeatureService).to receive(:enabled?).with(:routes_provider_led).and_return(false)
      end

      it "returns false" do
        expect(subject.requires_placement_details?).to be false
      end
    end
  end
end
