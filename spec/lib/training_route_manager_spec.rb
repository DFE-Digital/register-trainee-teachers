# frozen_string_literal: true

require "rails_helper"

describe TrainingRouteManager do
  subject { described_class.new(trainee) }

  describe "#requires_placement_details?" do
    context "with the :routes_provider_led_postgrad feature flag enabled", feature_routes_provider_led_postgrad: true do
      context "with a provider-led trainee" do
        let(:trainee) { build(:trainee, :provider_led_postgrad) }

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

    context "with the :routes_provider_led_postgrad feature flag disabled", feature_routes_provider_led_postgrad: false do
      let(:trainee) { build(:trainee, :provider_led_postgrad) }

      it "returns false" do
        expect(subject.requires_placement_details?).to be false
      end
    end
  end
end
